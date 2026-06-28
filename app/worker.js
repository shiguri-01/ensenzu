import { render_api_response_json } from "../_build/js/debug/build/shiguri-01/app/app.js";

const jsonHeaders = {
  "Content-Type": "application/json; charset=utf-8",
  "Cache-Control": "no-store",
};

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

      return new Response(render_api_response_json(await request.text()), {
        headers: jsonHeaders,
      });
    }

    return env.ASSETS.fetch(request);
  },
};
