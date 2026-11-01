<script lang="ts">
	import { register, AuthError } from '#lib/auth.svelte.ts';

	let email = $state('');
	let password = $state('');
	let errors = $state<string[]>([]);
	let loading = $state(false);

	async function onSubmit(e: SubmitEvent) {
		e.preventDefault();
		errors = [];
		loading = true;
		try {
			await register(email, password);
		} catch (err) {
			errors = err instanceof AuthError ? err.messages : ['Erro inesperado ao registrar'];
		} finally {
			loading = false;
		}
	}
</script>

<main class="narrow">
	<div class="card">
		<h1>Criar conta</h1>
		<form class="stack" onsubmit={onSubmit}>
			<label>
				E-mail
				<input type="email" bind:value={email} autocomplete="username" required />
			</label>
			<label>
				Senha
				<input type="password" bind:value={password} autocomplete="new-password" required />
			</label>
			{#each errors as message}
				<p class="error" role="alert">{message}</p>
			{/each}
			<button type="submit" disabled={loading}>{loading ? 'Criando…' : 'Criar conta'}</button>
		</form>
		<p class="muted">Já tem conta? <a href="/login">Entrar</a></p>
	</div>
</main>
