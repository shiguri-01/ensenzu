const jsonHeaders = {
  "Content-Type": "application/json; charset=utf-8",
  "Cache-Control": "no-store",
};

let renderApiResponseJson;

async function renderDiagramResponse(requestBody) {
  if (!renderApiResponseJson) {
    const api = await import("../_build/js/debug/build/shiguri-01/app/app.js");
    renderApiResponseJson = api.render_api_response_json;
  }
  return renderApiResponseJson(requestBody);
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (url.pathname === "/api/diagram") {
      if (request.method !== "POST") {
        return new Response(
          JSON.stringify({
            ok: false,
            error: "Method not allowed. Use POST /api/diagram.",
          }),
          { status: 405, headers: jsonHeaders },
        );
      }

      return new Response(await renderDiagramResponse(await request.text()), {
        headers: jsonHeaders,
      });
    }

    return env.ASSETS.fetch(request);
  },
};
