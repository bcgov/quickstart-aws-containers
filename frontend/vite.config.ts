import { defineConfig } from 'vite'
import { fileURLToPath, URL } from 'node:url'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    port: parseInt(process.env.PORT),
    fs: {
      // Allow serving files from one level up to the project root
      allow: ['..'],
    },
    proxy: {
      // Proxy API requests to the backend
      '/api': {
        target: process.env.BACKEND_URL || 'http://localhost:3001',
        changeOrigin: true,
      },
    },
  },
  resolve: {
    // https://vitejs.dev/config/shared-options.html#resolve-alias
    alias: {
      '@': fileURLToPath(new URL('./src', import.meta.url)),
      '~': fileURLToPath(new URL('./node_modules', import.meta.url)),
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
          react: [
            'react',
          ],
          reactDom: ['react-dom'],
          reactRouter: ['react-router-dom', 'react-router'],
          emotionReact: ['@emotion/react', '@emotion/styled'],
          muiSystem: ['@mui/system'],
          muimaterial: ['@mui/material'],
          muiicons: ['@mui/icons-material'],
          muidataGrid: ['@mui/x-data-grid'],
          axios: ['axios'],
        },
      },
    },
  },
})
