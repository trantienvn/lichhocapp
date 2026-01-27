const CACHE_NAME = 'v1.0.5';
const PRECACHE_ASSETS = [
    '/',
    '/index.js',
    '/index.html',
    '/manifest.json',
    '/favicon.ico',
];

// Install Event: Pre-cache essential assets
self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => {
            return cache.addAll(PRECACHE_ASSETS);
        })
    );
    self.skipWaiting();
});

// Activate Event: Cleanup old caches
self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys().then((cacheNames) => {
            return Promise.all(
                cacheNames.map((cacheName) => {
                    if (cacheName !== CACHE_NAME) {
                        return caches.delete(cacheName);
                    }
                })
            );
        })
    );
    event.waitUntil(self.clients.claim());
});

// Fetch Event: Stale-While-Revalidate Strategy
self.addEventListener('fetch', (event) => {
    // Only handle GET requests and skip chrome-extension/other non-http schemes
    if (event.request.method !== 'GET' || !event.request.url.startsWith('http')) return;

    event.respondWith(
        caches.match(event.request).then((cachedResponse) => {
            // Revalidate in background
            const fetchPromise = fetch(event.request).then((networkResponse) => {
                // Check if response is valid (not 5xx error)
                if (networkResponse && networkResponse.ok) {
                    const responseToCache = networkResponse.clone();
                    caches.open(CACHE_NAME).then((cache) => {
                        cache.put(event.request, responseToCache);
                    });
                }
                return networkResponse;
            }).catch(() => {
                // Network failure
                return cachedResponse;
            });

            // For navigation requests, try network first but fallback to cache fast
            if (event.request.mode === 'navigate') {
                return fetch(event.request.url)
                    .then((networkResponse) => {
                        // If network is OK (not 530/500), return it
                        if (networkResponse.ok) return networkResponse;
                        // If 5xx error (like 530), use cache
                        return cachedResponse || networkResponse;
                    })
                    .catch(() => cachedResponse);
            }

            // Return cached response immediately, or wait for network
            return cachedResponse || fetchPromise;
        })
    );
});

// Message Listener for Skip Waiting
self.addEventListener('message', (event) => {
    if (event.data && event.data.type === 'SKIP_WAITING') {
        self.skipWaiting();
    }
});
