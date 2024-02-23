const random = (probabilities) => {
    const keys = Object.keys(probabilities)
    const values = Object.values(probabilities)

    const totalProb = values.reduce((acc, prob) => acc + prob, 0)
    if (Math.abs(totalProb - 1) > 0.0001) {
        throw new Error('Probabilities must add up to 1')
    }
    const normalizedProb = values.map((prob) => prob / totalProb)

    const randomValue = Math.random()
    let cumulativeProb = 0

    return (
        keys.find(
            (_, i) => (cumulativeProb += normalizedProb[i]) >= randomValue,
        ) || keys[keys.length - 1]
    )
}

const html = (title) => `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${title}</title>
    <meta property="og:title" content="${title}">
    <meta property="og:description" content="${title}">
    <style>
        body {
            font-family: 'Arial', sans-serif;
            margin: 0;
            padding: 0;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            background-color: #3498db; /* Nice blue color */
        }

        h1 {
            color: #ecf0f1; /* Light gray text color */
            text-align: center;
            padding: 20px;
            border: 2px solid #2980b9; /* Darker blue border */
            border-radius: 10px;
            background-color: #2c3e50; /* Darker blue background */
            box-shadow: 0 0 20px rgba(0, 0, 0, 0.3); /* Larger and darker box shadow */
            font-size: 5em; /* Larger font size */
        }
    </style>
</head>
<body>
    <h1>${title}</h1>
</body>
</html>
`

export default server(
    (r) => {
        r.get('/', (request, env, ctx) => {
            const games = JSON.parse(env.games)
            const game = random(games)
            return new Response(html(game), {
                headers: {
                    'content-type': 'text/html;charset=UTF-8',
                },
            })
        })
        r.get('/:name', (request, env, ctx) => {
            const name = request.params.name
            return new Response(`Hello ${name}!`)
        })
    },
    (env, ctx) => {
        console.log('cron scheduled event', JSON.stringify(env))
    },
)
