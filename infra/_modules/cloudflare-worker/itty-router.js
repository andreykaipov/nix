// node_modules/itty-router/index.mjs
var e = ({ base: e2 = "", routes: t = [] } = {}) => ({ __proto__: new Proxy({}, { get: (o2, s2, r2, n2) => (o3, ...a) => t.push([s2.toUpperCase(), RegExp(`^${(n2 = (e2 + "/" + o3).replace(/\/+(\/|$)/g, "$1")).replace(/(\/?\.?):(\w+)\+/g, "($1(?<$2>*))").replace(/(\/?\.?):(\w+)/g, "($1(?<$2>[^$1/]+?))").replace(/\./g, "\\.").replace(/(\/?)\*/g, "($1.*)?")}/*$`), a, n2]) && r2 }), routes: t, async handle(e3, ...o2) {
  let s2, r2, n2 = new URL(e3.url), a = e3.query = { __proto__: null };
  for (let [e4, t2] of n2.searchParams)
    a[e4] = void 0 === a[e4] ? t2 : [a[e4], t2].flat();
  for (let [a2, c, l2, i2] of t)
    if ((a2 === e3.method || "ALL" === a2) && (r2 = n2.pathname.match(c))) {
      e3.params = r2.groups || {}, e3.route = i2;
      for (let t2 of l2)
        if (void 0 !== (s2 = await t2(e3.proxy || e3, ...o2)))
          return s2;
    }
} });
var o = (e2 = "text/plain; charset=utf-8", t) => (o2, s2) => {
  const { headers: r2 = {}, ...n2 } = s2 || {};
  return "Response" === o2?.constructor.name ? o2 : new Response(t ? t(o2) : o2, { headers: { "content-type": e2, ...r2 }, ...n2 });
};
var s = o("application/json; charset=utf-8", JSON.stringify);
var r = (e2) => ({ 400: "Bad Request", 401: "Unauthorized", 403: "Forbidden", 404: "Not Found", 500: "Internal Server Error" })[e2] || "Unknown Error";
var n = (e2 = 500, t) => {
  if (e2 instanceof Error) {
    const { message: o2, ...s2 } = e2;
    e2 = e2.status || 500, t = { error: o2 || r(e2), ...s2 };
  }
  return t = { status: e2, ..."object" == typeof t ? t : { error: t || r(e2) } }, s(t, { status: e2 });
};
var l = o("text/html");
var i = o("image/jpeg");
var p = o("image/png");
var d = o("image/webp");
