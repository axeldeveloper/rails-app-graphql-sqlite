# books-front

Front SvelteKit (SPA estático) para a API Rails GraphQL de autores e livros.

## Como a autenticação funciona

- `POST /api/v1/auth/login|register` devolve `{ user, access_token }` e o Rails grava o refresh token em cookie HttpOnly (`path=/api/v1/auth`, `SameSite=Lax`).
- O access token fica **só em memória** (`src/lib/auth.svelte.ts`). Ao abrir/recarregar o app, `restore()` chama `POST /api/v1/auth/refresh` para recuperar a sessão pelo cookie.
- O refresh é rotativo: chamadas simultâneas compartilham uma única requisição (single-flight).
- `gql()` (`src/lib/api.ts`) envia `Authorization: Bearer`, e em 401 renova o token uma vez e repete a operação.
- O navegador envia `Origin` automaticamente em `refresh`/`logout`; o Rails o compara com `config.x.authentication.allowed_origin`.

## Desenvolvimento

```bash
npm install
RAILS_URL=http://localhost:3000 npm run dev   # http://localhost:5173
```

O Vite faz proxy de `/api` e `/graphql` para o Rails, então front e API ficam na mesma origem
(necessário para o cookie de refresh). No Rails, configure
`allowed_origin = "http://localhost:5173"` em desenvolvimento.

## Produção

`npm run build` gera `build/` (estático, com CSP via meta tag). Sirva com Nginx na mesma origem da API:

```nginx
server {
  root /var/www/books-front/build;

  location /api/     { proxy_pass http://127.0.0.1:3000; proxy_set_header Host $host; proxy_set_header X-Forwarded-Proto $scheme; }
  location /graphql  { proxy_pass http://127.0.0.1:3000; proxy_set_header Host $host; proxy_set_header X-Forwarded-Proto $scheme; }
  location /         { try_files $uri $uri/ /index.html; }

  add_header X-Content-Type-Options nosniff always;
  add_header Referrer-Policy same-origin always;
  add_header Content-Security-Policy "frame-ancestors 'none'" always;
}
```

Em produção o cookie usa `Secure`, então é necessário HTTPS (e `allowed_origin` com `https://seu-dominio`).
