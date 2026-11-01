import{a as e,n as t}from"./XfiNgDy_.js";var n=`
	query ListAuthors {
		authors {
			id
			firstName
			lastName
			dateOfBirth
		}
	}
`,r=`
	query FindAuthorWithBooks($id: ID!) {
		author(id: $id) {
			id
			firstName
			lastName
			books {
				id
				title
				genre
				publicationDate
			}
		}
	}
`,i=`
	query ListBooks {
		books {
			id
			title
			genre
			publicationDate
			author {
				id
				firstName
				lastName
			}
		}
	}
`,a=`
	query FindBook($id: ID!) {
		book(id: $id) {
			id
			title
			genre
			publicationDate
			author {
				id
				firstName
				lastName
				dateOfBirth
			}
		}
	}
`,o=`
	mutation UpdateBook($id: Int!, $title: String, $genre: Genre) {
		updateBook(id: $id, title: $title, genre: $genre) {
			id
			title
			genre
			publicationDate
		}
	}
`,s=`
	mutation DeleteBook($id: Int!) {
		destroyBook(id: $id) {
			id
			title
		}
	}
`,c=/^[A-Z][A-Za-z0-9_]*$/,l=/^\d{4}-\d{2}-\d{2}$/;function u(e){if(!l.test(e.dateOfBirth))throw Error(`Data de nascimento inválida`);return`mutation CreateAuthor {
		createAuthor(
			firstName: ${JSON.stringify(e.firstName)}
			lastName: ${JSON.stringify(e.lastName)}
			dateOfBirth: ${JSON.stringify(e.dateOfBirth)}
		) {
			author { id firstName lastName dateOfBirth }
			errors
		}
	}`}function d(e){if(!Number.isInteger(e.authorId)||!Number.isInteger(e.publicationDate))throw Error(`Autor e ano devem ser números inteiros`);if(!c.test(e.genre))throw Error(`Gênero inválido`);return`mutation CreateBook {
		createBook(
			title: ${JSON.stringify(e.title)}
			authorId: ${e.authorId}
			publicationDate: ${e.publicationDate}
			genre: ${e.genre}
		) {
			id title genre publicationDate
		}
	}`}var f=`/graphql`,p=class extends Error{messages;constructor(e){super(e.join(`; `)),this.messages=e}};function m(e,n){let r=t();return fetch(f,{method:`POST`,credentials:`same-origin`,headers:{"Content-Type":`application/json`,Accept:`application/json`,...r?{Authorization:`Bearer ${r}`}:{}},body:JSON.stringify({query:e,variables:n})})}async function h(t,n){let r=await m(t,n);if(r.status===401&&await e()&&(r=await m(t,n)),r.status===401)throw new p([`Sessão expirada. Faça login novamente.`]);let i=await r.json().catch(()=>null);if(!r.ok&&!i)throw new p([`Erro ${r.status} ao chamar a API`]);if(i?.errors?.length)throw new p(i.errors.map(e=>e.message));return i.data}var g=[`Mystery`],_=null;async function v(){if(_)return _;try{let e=(await h(`
	query GenreValues {
		__type(name: "Genre") {
			enumValues {
				name
			}
		}
	}
`)).__type?.enumValues.map(e=>e.name)??[];_=e.length?e:g}catch{_=g}return _}export{r as a,i as c,d,s as i,o as l,h as n,a as o,v as r,n as s,p as t,u};