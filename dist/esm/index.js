import { registerPlugin } from '@capacitor/core';
export const CactusCap = registerPlugin('CactusCap', {
    web: () => import('./web').then(m => new m.CactusCapWeb()),
});
export * from './definitions';
//# sourceMappingURL=index.js.map