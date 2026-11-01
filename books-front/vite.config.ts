import adapter from '@sveltejs/adapter-static';
import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';

// URL do Rails em desenvolvimento. Em produção, use um proxy reverso (Nginx)
// servindo o front e encaminhando /api e /graphql para o Rails no MESMO host,
// para o cookie de refresh (SameSite=Lax, path /api/v1/auth) funcionar.
const RAILS_URL = process.env.RAILS_URL ?? 'http://localhost:3000';

export default defineConfig({
	plugins: [
		sveltekit({
			compilerOptions: {
				runes: ({ filename }) =>
					filename.split(/[/\\]/).includes('node_modules') ? undefined : true
			},

			// SPA estático: o servidor só entrega arquivos, token nunca passa por SSR.
			adapter: adapter({ fallback: 'index.html' }),

			csp: {
				mode: 'auto',
				directives: {
					'default-src': ['self'],
					'script-src': ['self'],
					'style-src': ['self', 'unsafe-inline'],
					'img-src': ['self', 'data:'],
					'connect-src': ['self'],
					'object-src': ['none'],
					'base-uri': ['self'],
					'form-action': ['self']
				}
			}
		})
	],
	server: {
		proxy: {
			'/api': RAILS_URL,
			'/graphql': RAILS_URL
		}
	}
});
