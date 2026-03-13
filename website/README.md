# SetupX Website

Frontend site for SetupX, built with React + Vite and deployed on Vercel.

## Live Website

- https://setupx.vercel.app

## Scripts

```bash
npm run dev            # Start local dev server
npm run lint           # Run ESLint
npm run build          # Create production build in dist/
npm run preview        # Preview production build locally
npm run vercel:dev     # Run Vercel local environment
npm run vercel:deploy  # Deploy to Vercel production
```

## Build

```bash
npm install
npm run build
```

The app output is generated in `dist/`.

## Deploy

```bash
npm install
npm run vercel:deploy
```

Vercel settings are defined in `vercel.json`:
- Framework: `vite`
- Build command: `npm run build`
- Output directory: `dist`

## Notes

- Module cards are interactive and reveal all components on click.
- Each component provides a copy button for the install command.
- Component install command format is `sx install <component>`.
