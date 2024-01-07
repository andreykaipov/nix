const random = (arr) => {
    return arr[Math.floor(Math.random() * arr.length)]
}

export default server((r) => {
    r.get('/', (request, env, ctx) => {
        const links = JSON.parse(env.links)
        const link = random(links)
        return new Response(link, {
            status: 302,
            headers: {
                Location: link,
                'Cache-Control': 'no-cache, no-store, must-revalidate',
                Pragma: 'no-cache',
                Expires: 0,
            },
        })
    })
})
