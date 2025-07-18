import { defineConfig, loadEnv } from 'vite'
import { fileURLToPath, URL } from 'node:url'
import react from '@vitejs/plugin-react'
import { TanStackRouterVite } from '@tanstack/router-plugin/vite'

export default ({ mode }) => {
  // Load app-level env vars to node-level env vars.
  const loadedEnv = loadEnv(mode, process.cwd());
  for (const [key, value] of Object.entries(loadedEnv)) {
    if (key.startsWith('VITE_')) {
      process.env[key] = value;
    }
  }

  const define: Record<string, any> = {
    'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV),
  }
  return defineConfig({
    define,
    plugins: [
      TanStackRouterVite({
        target: 'react',
        autoCodeSplitting: true,
      }),
      react(),
    ],
    server: {
      port: parseInt(process.env.VITE_PORT, 10),
      fs: {
        // Allow serving files from one level up to the project root
        allow: ['..'],
      },
      proxy: {
        // Proxy API requests to the backend
        '/api': {
          target: process.env.VITE_API_BASE_URL || 'http://localhost:3001',
          changeOrigin: true,
        },
      },
    },
    resolve: {
      // https://vitejs.dev/config/shared-options.html#resolve-alias
      alias: {
        '@': fileURLToPath(new URL('./src', import.meta.url)),
        '~': fileURLToPath(new URL('./node_modules', import.meta.url)),
        '~bootstrap': fileURLToPath(
          new URL('./node_modules/bootstrap', import.meta.url),
        ),
      },
      extensions: ['.js', '.json', '.jsx', '.mjs', '.ts', '.tsx', '.vue'],
    },
    build: {
      // Build Target
      // https://vitejs.dev/config/build-options.html#build-target
      target: 'esnext',
      // Minify option
      // https://vitejs.dev/config/build-options.html#build-minify
      minify: 'esbuild',
      // Rollup Options
      // https://vitejs.dev/config/build-options.html#build-rollupoptions
      rollupOptions: {
        output: {
          manualChunks: {
            // Split external library from transpiled code.
            react: ['react', 'react-dom'],
            axios: ['axios'],
          },
        },
      },
    },
    css: {
      preprocessorOptions: {
        scss: {
          // Silence deprecation warnings caused by Bootstrap SCSS
          // which is out of our control.
          silenceDeprecations: [
            'mixed-decls',
            'color-functions',
            'global-builtin',
            'import',
          ],
        },
      },
    },
  })
}
