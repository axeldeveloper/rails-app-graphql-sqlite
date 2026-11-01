<script lang="ts">
	import { login, AuthError } from '#lib/auth.svelte.ts';

	let email = $state('');
	let password = $state('');
	let error = $state('');
	let loading = $state(false);

	async function onSubmit(e: SubmitEvent) {
		e.preventDefault();
		error = '';
		loading = true;
		try {
			await login(email, password);
			// O layout redireciona para /books quando a sessão é criada.
		} catch (err) {
			error = err instanceof AuthError ? err.message : 'Erro inesperado ao entrar';
		} finally {
			loading = false;
		}
	}
</script>

<main class="narrow">
	<div class="card">
		<h1>Entrar</h1>
		<form class="stack" onsubmit={onSubmit}>
			<label>
				E-mail
				<input type="email" bind:value={email} autocomplete="username" required />
			</label>
			<label>
				Senha
				<input type="password" bind:value={password} autocomplete="current-password" required />
			</label>
			{#if error}<p class="error" role="alert">{error}</p>{/if}
			<button type="submit" disabled={loading}>{loading ? 'Entrando…' : 'Entrar'}</button>
		</form>
		<p class="muted">Não tem conta? <a href="/register">Criar conta</a></p>
	</div>
</main>
