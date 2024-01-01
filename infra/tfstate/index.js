// adapated from https://github.com/louy/terraform-backend-cloudflare-worker

export default {
  async fetch(request, env) {
    return await handleRequest(request, env)
  }
}

async function handleRequest(request, env) {
  try {
    // Check authorisation
    let authError = await authenticate(request, env);
    if (authError) return authError;

    let requestURL = new URL(request.url);
    const module = requestURL.pathname.slice(1);
    switch (request.method) {
      case "GET":
        return await getState(env, module);
      case "POST":
        return await setState(env, module, await request.text());
      case "DELETE":
        return await deleteState(env, module);
      case "LOCK":
        return await lockState(env, module, await request.text());
      case "UNLOCK":
        return await unlockState(env, module, await request.text());
    }

    return new Response(`Nothing found for $${module}`, {
      status: 404,
    });
  } catch (error) {
    return new Response(error.stack, { status: 500 });
  }
}

async function authenticate(request, env) {
  const username = env.username
  const password = env.password
  const expectedCredentials = btoa([username, password].join(':'));

  const authHeader = request.headers.get('Authorization');
  if (!authHeader || typeof authHeader !== 'string') {
    return new Response('Eat more tomatoes', {
      status: 401,
      headers: {
        'WWW-Authenticate': 'Basic realm="Terraform State"',
      },
    });
  }

  const [scheme, credentials, ...rest] = authHeader.split(' ');
  if (rest.length != 0 || scheme !== 'Basic' || credentials !== expectedCredentials) {
    return new Response('Invalid credentials', {
      status: 403,
      headers: {
        'WWW-Authenticate': 'Basic realm="Terraform State"',
      },
    });
  }

  return void 0;
}

//
// handle state
//

async function getState(env, path) {
  const state = await env.tfstate.get(`state://$${path}`);
  if (!state) {
    return new Response('', {
      status: 404,
      headers: {
        'Cache-Control': 'no-store',
      },
    });
  }

  return new Response(state || '', {
    headers: {
      'Content-type': 'application/json',
      'Cache-Control': 'no-store',
    },
  });
}
async function setState(env, path, body) {
  await env.tfstate.put(`state://$${path}`, body);
  return new Response(body || '', {
    status: 200,
    headers: {
      'Content-type': 'application/json',
      'Cache-Control': 'no-store',
    },
  });
}
async function deleteState(env, path) {
  await env.tfstate.delete(`state://$${path}`);
  return new Response('', {
    status: 200,
    headers: {
      'Cache-Control': 'no-store',
    },
  });
}

//
// handle locks
//

async function lockState(env, path, body) {
  const existingLock = await env.tfstate.get(`lock://$${path}`);
  if (existingLock) {
    return new Response(existingLock, {
      status: 423,
      headers: {
        'Content-type': 'application/json',
        'Cache-Control': 'no-store',
      },
    });
  }
  await env.tfstate.put(`lock://$${path}`, body);
  return new Response(body, {
    status: 200,
    headers: {
      'Content-type': 'application/json',
      'Cache-Control': 'no-store',
    },
  });
}

async function unlockState(env, path, body) {
  await env.tfstate.delete(`lock://$${path}`);
  return new Response('', {
    status: 200,
    headers: {
      'Cache-Control': 'no-store',
    },
  });
}
