// https://developers.cloudflare.com/workers/examples/redirect#redirect-requests-from-one-domain-to-another

const base = "https://kaipov.com"
const statusCode = 301

async function handleRequest(request) {
  const url = new URL(request.url)
  const { pathname, search } = url
  const destinationURL = base + pathname + search
  return Response.redirect(destinationURL, statusCode)
}

addEventListener("fetch", async event => {
  event.respondWith(handleRequest(event.request))
})
