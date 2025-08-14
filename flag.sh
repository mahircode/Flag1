# app.py
from fastapi import FastAPI, Response
from fastapi.responses import HTMLResponse
import math

app = FastAPI(
    title="Indian Flag Microservice",
    description="Accurate SVG of the Indian national flag (3:2). Chakra per BIS proportion.",
    version="1.1.0",
)

# Default width; height is derived to keep 3:2
DEFAULT_WIDTH = 900

# Colors (commonly used approximations)
INDIA_SAFFRON = "#FF671F"
WHITE = "#FFFFFF"
INDIA_GREEN = "#046A38"
NAVY_BLUE = "#06038D"

def svg_indian_flag(width: int) -> str:
    # Enforce 3:2 aspect ratio (length:height = 3:2)
    w = max(90, int(width))
    h = int(round(w * 2 / 3))

    # Bands
    band_h = h / 3.0

    # Ashoka Chakra: BIS tables imply diameter ≈ 0.30833 * H (e.g., 600→185, 1200→370)
    chakra_d = h * (370.0 / 1200.0)  # == 0.308333...
    r = chakra_d / 2.0
    cx, cy = w / 2.0, h / 2.0

    # Stroke/geometry proportions (not specified in Flag Code; chosen for legibility)
    ring_stroke = max(1.0, w * 0.0085)    # outer ring thickness
    spoke_stroke = max(1.0, w * 0.0035)   # spoke thickness
    hub_r = r * 0.075                      # small solid center

    # Build 24 spokes
    spokes = []
    for i in range(24):
        theta = (2 * math.pi * i) / 24.0
        x2 = cx + r * math.cos(theta)
        y2 = cy + r * math.sin(theta)
        spokes.append(
            f'<line x1="{cx}" y1="{cy}" x2="{x2}" y2="{y2}" '
            f'stroke="{NAVY_BLUE}" stroke-width="{spoke_stroke}" />'
        )

    return f'''<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" viewBox="0 0 {w} {h}" role="img" aria-label="Flag of India">
  <!-- Tricolour bands -->
  <rect x="0" y="0"         width="{w}" height="{band_h}"     fill="{INDIA_SAFFRON}"/>
  <rect x="0" y="{band_h}"  width="{w}" height="{band_h}"     fill="{WHITE}"/>
  <rect x="0" y="{2*band_h}" width="{w}" height="{band_h}"    fill="{INDIA_GREEN}"/>

  <!-- Ashoka Chakra -->
  <circle cx="{cx}" cy="{cy}" r="{r}" fill="none" stroke="{NAVY_BLUE}" stroke-width="{ring_stroke}"/>
  {''.join(spokes)}
  <circle cx="{cx}" cy="{cy}" r="{hub_r}" fill="{NAVY_BLUE}"/>
</svg>'''

@app.get("/", response_class=HTMLResponse)
def home():
    return """
    <html>
      <head><title>Indian Flag Microservice</title></head>
      <body style="font-family: system-ui, -apple-system, Segoe UI, Roboto, Helvetica, Arial; line-height:1.5">
        <h1>Indian Flag Microservice</h1>
        <p>Endpoints:</p>
        <ul>
          <li><a href="/flag.svg">/flag.svg</a> — default width=900 (height auto 3:2)</li>
          <li><a href="/flag.svg?width=1200">/flag.svg?width=1200</a> — custom width</li>
        </ul>
      </body>
    </html>
    """

@app.get("/flag.svg")
def flag_svg(width: int = DEFAULT_WIDTH):
    svg = svg_indian_flag(width)
    return Response(content=svg, media_type="image/svg+xml")
