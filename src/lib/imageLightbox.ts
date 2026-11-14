import '../styles/image-lightbox.css';

/** Enhance figures marked data-image-lightbox. Returns cleanup for page navigation.
 * Each figure needs images inside data-image-lightbox-media; figcaption is optional.
 * The visible image's current source, alt text, and theme treatment are preserved.
 */
export function initImageLightboxes(root: ParentNode = document): () => void {
  const controller = new AbortController();
  const { signal } = controller;
  const triggers: HTMLButtonElement[] = [];
  const dialog = document.createElement('dialog');
  dialog.className = 'image-lightbox';
  dialog.setAttribute('aria-label', 'Enlarged image');
  dialog.setAttribute('data-pagefind-ignore', '');
  dialog.innerHTML = `
    <div class="image-lightbox-panel">
      <div class="image-lightbox-toolbar">
        <button type="button" data-close autofocus aria-label="Close enlarged image">Close ×</button>
      </div>
      <div class="image-lightbox-viewport" tabindex="0" aria-label="Enlarged image">
        <img class="image-lightbox-image" alt="" />
      </div>
      <p class="image-lightbox-caption"></p>
    </div>`;
  const image = dialog.querySelector<HTMLImageElement>('img')!;
  const caption = dialog.querySelector<HTMLElement>('.image-lightbox-caption')!;
  const viewport = dialog.querySelector<HTMLElement>('.image-lightbox-viewport')!;
  let opener: HTMLButtonElement | null = null;
  let previousOverflow: string | null = null;

  function restore() {
    if (previousOverflow !== null) document.documentElement.style.overflow = previousOverflow;
    previousOverflow = null;
    if (opener?.isConnected) opener.focus({ preventScroll: true });
    opener = null;
  }
  function close() {
    dialog.close();
    restore();
  }
  dialog.querySelector('[data-close]')!.addEventListener('click', close, { signal });
  dialog.addEventListener('click', event => {
    if (event.target === dialog) close();
  }, { signal });
  dialog.addEventListener('cancel', event => {
    event.preventDefault();
    close();
  }, { signal });
  dialog.addEventListener('close', () => {
    if (!dialog.open) restore();
  }, { signal });

  root.querySelectorAll<HTMLElement>('[data-image-lightbox]').forEach(figure => {
    const media = figure.querySelector<HTMLElement>('[data-image-lightbox-media]');
    if (!media || media.querySelector('.image-lightbox-trigger')) return;
    const trigger = document.createElement('button');
    trigger.type = 'button';
    trigger.className = 'image-lightbox-trigger';
    trigger.innerHTML = `<svg class="image-lightbox-icon" width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
      <path d="M8 16 16 8M10 8h6v6M14 16H8v-6" />
    </svg>`;
    trigger.setAttribute('aria-haspopup', 'dialog');
    trigger.setAttribute('aria-label', `Enlarge image: ${media.querySelector('img')?.alt || 'figure'}`);
    trigger.addEventListener('click', () => {
      const source = [...media.querySelectorAll('img')].find(img => getComputedStyle(img).display !== 'none');
      if (!source) return;
      image.src = source.currentSrc || source.src;
      image.alt = source.alt;
      image.dataset.themeAdapt = source.dataset.themeAdapt || '';
      image.style.filter = source.dataset.themeAdapt === 'invert' ? '' : getComputedStyle(source).filter;
      image.style.border = getComputedStyle(source).border;
      caption.textContent = figure.querySelector('figcaption')?.textContent || source.alt;
      viewport.scrollTo(0, 0);
      if (!dialog.isConnected) document.body.append(dialog);
      opener = trigger;
      previousOverflow = document.documentElement.style.overflow;
      document.documentElement.style.overflow = 'hidden';
      dialog.showModal();
    }, { signal });
    media.append(trigger);
    triggers.push(trigger);
  });
  return () => {
    if (dialog.open) dialog.close();
    restore();
    controller.abort();
    dialog.remove();
    triggers.forEach(trigger => trigger.remove());
  };
}
