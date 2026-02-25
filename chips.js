        (function () {
            'use strict';

            // ── Références DOM ────────────────────────────────────────────────
            const gallery     = document.getElementById('gallery');
            const searchInput = document.getElementById('search');
            const sortSelect  = document.getElementById('sort-select');
            const countBadge  = document.getElementById('chip-count');
            const noResults   = document.getElementById('no-results');
            const btnGrid     = document.getElementById('btn-grid');
            const btnList     = document.getElementById('btn-list');
            const backTop     = document.getElementById('back-to-top');
            const lightbox    = document.getElementById('lightbox');
            const lbImg       = document.getElementById('lightbox-img');
            const lbCap       = document.getElementById('lightbox-caption');
            const lbClose     = document.getElementById('lightbox-close');
            const lbPrev      = document.getElementById('lb-prev');
            const lbNext      = document.getElementById('lb-next');

            let current = 0;

            function getCards() { return Array.from(gallery.querySelectorAll('.chip-card')); }
            function visible()  { return getCards().filter(c => !c.classList.contains('hidden')); }

            // ── Compteur ──────────────────────────────────────────────────────
            function updateCount() {
                const v = visible().length, t = getCards().length;
                countBadge.innerHTML =
                    '<i class="fa-solid fa-layer-group"></i> ' +
                    (v < t ? v + ' / ' + t : t) + ' chips';
            }
            updateCount();

            // ── Recherche ─────────────────────────────────────────────────────
            if (searchInput) {
                searchInput.addEventListener('input', function () {
                    const q = searchInput.value.trim().toLowerCase();
                    let found = 0;
                    getCards().forEach(function (c) {
                        const match = !q || c.querySelector('figcaption').textContent.toLowerCase().includes(q);
                        c.classList.toggle('hidden', !match);
                        if (match) found++;
                    });
                    if (noResults) noResults.style.display = found === 0 ? 'flex' : 'none';
                    updateCount();
                });
            }

            // ── Tri ───────────────────────────────────────────────────────────
            if (sortSelect) {
                sortSelect.addEventListener('change', function () {
                    const cards = getCards();
                    if (sortSelect.value === 'random') {
                        cards.sort(function () { return Math.random() - 0.5; });
                    } else {
                        cards.sort(function (a, b) {
                            const na = parseInt(a.querySelector('figcaption').textContent.replace(/\D/g, '')) || 0;
                            const nb = parseInt(b.querySelector('figcaption').textContent.replace(/\D/g, '')) || 0;
                            return sortSelect.value === 'asc' ? na - nb : nb - na;
                        });
                    }
                    const frag = document.createDocumentFragment();
                    cards.forEach(function (c) { frag.appendChild(c); });
                    gallery.appendChild(frag);
                    updateCount();
                });
            }

            // ── Vue grille / liste ────────────────────────────────────────────
            if (btnGrid && btnList) {
                btnGrid.addEventListener('click', function () {
                    gallery.classList.remove('list-view');
                    btnGrid.classList.add('active');
                    btnList.classList.remove('active');
                });
                btnList.addEventListener('click', function () {
                    gallery.classList.add('list-view');
                    btnList.classList.add('active');
                    btnGrid.classList.remove('active');
                });
            }

            // ── Lightbox ──────────────────────────────────────────────────────
            function openAt(idx) {
                const vc = visible();
                if (!vc.length) return;
                current = ((idx % vc.length) + vc.length) % vc.length;
                const img = vc[current].querySelector('img');
                const cap = vc[current].querySelector('figcaption');
                lbImg.src = img.src;
                lbImg.alt = cap.textContent;
                lbCap.innerHTML =
                    '<i class="fa-solid fa-image"></i> ' + cap.textContent +
                    ' <span class="lb-counter">(' + (current + 1) + '\u202F/\u202F' + vc.length + ')</span>';
                lightbox.classList.add('open');
                document.body.style.overflow = 'hidden';
            }

            function closeLB() {
                lightbox.classList.remove('open');
                document.body.style.overflow = '';
            }

            // Add lazy-loading attribute to images for better mobile performance
            getCards().forEach(function (card) {
                const img = card.querySelector('img');
                if (img && !img.hasAttribute('loading')) img.setAttribute('loading', 'lazy');
                card.addEventListener('click', function () {
                    openAt(visible().indexOf(card));
                });
            });

            if (lbClose) lbClose.addEventListener('click', closeLB);
            if (lbPrev)  lbPrev.addEventListener('click',  function () { openAt(current - 1); });
            if (lbNext)  lbNext.addEventListener('click',  function () { openAt(current + 1); });
            if (lightbox) lightbox.addEventListener('click', function (e) { if (e.target === lightbox) closeLB(); });
            document.addEventListener('keydown', function (e) {
                if (!lightbox.classList.contains('open')) return;
                if (e.key === 'Escape')     closeLB();
                if (e.key === 'ArrowLeft')  openAt(current - 1);
                if (e.key === 'ArrowRight') openAt(current + 1);
            });

            // Swipe mobile & double-tap close
            var touchX = 0, lastTap = 0;
            if (lightbox) {
                lightbox.addEventListener('touchstart', function (e) {
                    touchX = e.touches[0].clientX;
                }, { passive: true });
                lightbox.addEventListener('touchend', function (e) {
                    var dx = e.changedTouches[0].clientX - touchX;
                    // swipe threshold scaled for small screens
                    var threshold = Math.min(window.innerWidth * 0.12, 60);
                    if (Math.abs(dx) > threshold) {
                        openAt(dx < 0 ? current + 1 : current - 1);
                        return;
                    }
                    // double-tap to close
                    var now = Date.now();
                    if (now - lastTap < 350) { closeLB(); }
                    lastTap = now;
                }, { passive: true });

                // On small screens, make the lightbox content take the whole screen
                function adjustLBForViewport() {
                    if (window.innerWidth <= 480) {
                        lightbox.classList.add('mobile');
                    } else {
                        lightbox.classList.remove('mobile');
                    }
                }
                window.addEventListener('resize', adjustLBForViewport);
                adjustLBForViewport();
            }

            // ── Bouton retour en haut ─────────────────────────────────────────
            if (backTop) {
                window.addEventListener('scroll', function () {
                    backTop.classList.toggle('visible', window.scrollY > 400);
                });
                backTop.addEventListener('click', function () {
                    window.scrollTo({ top: 0, behavior: 'smooth' });
                });
            }
        })();