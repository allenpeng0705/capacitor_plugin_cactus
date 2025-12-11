import { registerPlugin } from '@capacitor/core';
import type { CactusCapPlugin } from './definitions';

export const CactusCap = registerPlugin<CactusCapPlugin>('CactusCap', {
  web: () => import('./web').then(m => new m.CactusCapWeb()),
});

export * from './definitions';
