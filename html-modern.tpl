<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
{{- if . }}
<title>{{ escapeXML ( index . 0 ).Target }} — Trivy Report — {{ now }}</title>
<style>
  :root{
    --bg:#f6f7fb; --card:#ffffff; --border:#e5e7eb; --text:#111827; --muted:#6b7280;
    --crit:#dc2626; --crit-bg:#fee2e2;
    --high:#ea580c; --high-bg:#ffedd5;
    --med:#ca8a04;  --med-bg:#fef3c7;
    --low:#16a34a;  --low-bg:#dcfce7;
    --unk:#6b7280;  --unk-bg:#e5e7eb;
    --accent:#4f46e5;
  }
  *{box-sizing:border-box;}
  body{
    margin:0; background:var(--bg); color:var(--text);
    font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,Helvetica,Arial,sans-serif;
    -webkit-font-smoothing:antialiased;
  }
  header.top{
    background:linear-gradient(135deg,#1e1b4b,#312e81 60%,#4f46e5);
    color:#fff; padding:28px 32px;
  }
  header.top h1{margin:0 0 6px; font-size:22px; font-weight:700; word-break:break-all;}
  header.top p{margin:0; color:#c7d2fe; font-size:13px;}

  .wrap{max-width:1200px; margin:0 auto; padding:24px 20px 60px;}

  .cards{
    display:grid; grid-template-columns:repeat(5,1fr); gap:12px;
    margin:-20px 0 22px;
  }
  .card{
    background:var(--card); border:1px solid var(--border); border-radius:12px;
    padding:14px 16px; cursor:pointer; box-shadow:0 1px 2px rgba(0,0,0,.04);
    transition:transform .12s, box-shadow .12s; user-select:none;
  }
  .card:hover{transform:translateY(-2px); box-shadow:0 6px 16px rgba(0,0,0,.08);}
  .card.active{outline:2px solid var(--accent);}
  .card .num{font-size:26px; font-weight:800; line-height:1;}
  .card .lbl{font-size:11px; font-weight:700; letter-spacing:.04em; text-transform:uppercase; margin-top:4px; opacity:.75;}
  .card.crit .num{color:var(--crit);} .card.high .num{color:var(--high);}
  .card.med .num{color:var(--med);}   .card.low .num{color:var(--low);}
  .card.unk .num{color:var(--unk);}

  .controls{
    display:flex; gap:10px; align-items:center; flex-wrap:wrap;
    margin-bottom:18px; position:sticky; top:0; background:var(--bg); padding:10px 0; z-index:5;
  }
  #search{
    flex:1; min-width:220px; padding:10px 14px; border:1px solid var(--border); border-radius:8px;
    font-size:14px; background:#fff;
  }
  #search:focus{outline:2px solid var(--accent); border-color:transparent;}
  .pill{
    border:1px solid var(--border); background:#fff; border-radius:20px; padding:7px 14px;
    font-size:12px; font-weight:600; cursor:pointer; color:var(--muted);
  }
  .pill.active{background:var(--accent); color:#fff; border-color:var(--accent);}

  section.target{
    background:var(--card); border:1px solid var(--border); border-radius:12px;
    margin-bottom:16px; overflow:hidden;
  }
  section.target > .head{
    padding:14px 18px; display:flex; align-items:center; justify-content:space-between;
    cursor:pointer; background:#fafafa; border-bottom:1px solid var(--border);
  }
  section.target > .head h2{margin:0; font-size:14px; font-weight:700;}
  section.target > .head .meta{font-size:12px; color:var(--muted);}
  section.target > .head .chevron{transition:transform .15s; color:var(--muted);}
  section.target.collapsed > .head .chevron{transform:rotate(-90deg);}
  section.target.collapsed > .body{display:none;}

  table{width:100%; border-collapse:collapse; font-size:13px;}
  thead th{
    text-align:left; font-size:11px; text-transform:uppercase; letter-spacing:.03em;
    color:var(--muted); padding:10px 14px; border-bottom:1px solid var(--border);
  }
  tbody td{padding:10px 14px; border-bottom:1px solid var(--border); vertical-align:top;}
  tbody tr:last-child td{border-bottom:none;}
  tbody tr:hover{background:#fafbff;}
  .pkg{font-weight:700;}
  .badge{
    display:inline-block; padding:3px 10px; border-radius:20px; font-size:11px; font-weight:700;
    letter-spacing:.02em;
  }
  .badge.CRITICAL{color:var(--crit); background:var(--crit-bg);}
  .badge.HIGH{color:var(--high); background:var(--high-bg);}
  .badge.MEDIUM{color:var(--med); background:var(--med-bg);}
  .badge.LOW{color:var(--low); background:var(--low-bg);}
  .badge.UNKNOWN{color:var(--unk); background:var(--unk-bg);}
  .links a{display:block; font-size:11px; color:var(--accent); text-decoration:none; margin-bottom:2px;}
  .links a:hover{text-decoration:underline;}
  .links{max-width:260px; overflow:hidden;}
  .title-cell{max-width:340px; color:var(--muted); font-size:12px;}
  .empty-state{
    padding:24px; text-align:center; color:var(--low); font-weight:600; font-size:13px;
  }
  .hidden-row{display:none !important;}
  footer{text-align:center; color:var(--muted); font-size:11px; padding:20px 0;}
</style>
</head>
<body>
  <header class="top">
    <h1>{{ escapeXML ( index . 0 ).Target }}</h1>
    <p>Trivy security scan &nbsp;•&nbsp; generated {{ now }}</p>
  </header>

  <div class="wrap">
    <div class="cards">
      <div class="card crit" data-sev="CRITICAL"><div class="num" id="cnt-CRITICAL">0</div><div class="lbl">Critical</div></div>
      <div class="card high" data-sev="HIGH"><div class="num" id="cnt-HIGH">0</div><div class="lbl">High</div></div>
      <div class="card med"  data-sev="MEDIUM"><div class="num" id="cnt-MEDIUM">0</div><div class="lbl">Medium</div></div>
      <div class="card low"  data-sev="LOW"><div class="num" id="cnt-LOW">0</div><div class="lbl">Low</div></div>
      <div class="card unk"  data-sev="UNKNOWN"><div class="num" id="cnt-UNKNOWN">0</div><div class="lbl">Unknown</div></div>
    </div>

    <div class="controls">
      <input id="search" type="text" placeholder="Search package, CVE, or message…">
      <button class="pill active" data-filter="ALL">All</button>
    </div>

    {{- range . }}
    <section class="target">
      <div class="head" onclick="this.parentElement.classList.toggle('collapsed')">
        <div>
          <h2>{{ escapeXML .Target }}</h2>
          <span class="meta">{{ .Type | toString | escapeXML }}</span>
        </div>
        <span class="chevron">&#9660;</span>
      </div>
      <div class="body">

      {{- if (eq (len .Vulnerabilities) 0) }}
      <div class="empty-state">✓ No vulnerabilities found</div>
      {{- else }}
      <table>
        <thead>
          <tr>
            <th>Package</th><th>Vulnerability</th><th>Severity</th>
            <th>Installed</th><th>Fixed In</th><th>Description</th><th>References</th>
          </tr>
        </thead>
        <tbody>
        {{- range .Vulnerabilities }}
          <tr class="row" data-severity="{{ escapeXML .Vulnerability.Severity }}">
            <td class="pkg">{{ escapeXML .PkgName }}</td>
            <td>{{ escapeXML .VulnerabilityID }}</td>
            <td><span class="badge {{ escapeXML .Vulnerability.Severity }}">{{ escapeXML .Vulnerability.Severity }}</span></td>
            <td>{{ escapeXML .InstalledVersion }}</td>
            <td>{{ escapeXML .FixedVersion }}</td>
            <td class="title-cell">{{ escapeXML .Vulnerability.Title }}</td>
            <td class="links">
              {{- range $i, $ref := .Vulnerability.References }}{{ if lt $i 2 }}
              <a href="{{ escapeXML $ref | printf "%q" }}" target="_blank" rel="noopener">{{ escapeXML $ref }}</a>
              {{- end }}{{- end }}
            </td>
          </tr>
        {{- end }}
        </tbody>
      </table>
      {{- end }}

      {{- if (eq (len .Misconfigurations) 0) }}
      <div class="empty-state">✓ No misconfigurations found</div>
      {{- else }}
      <table>
        <thead>
          <tr><th>Check</th><th>ID</th><th>Severity</th><th>Message</th><th>Reference</th></tr>
        </thead>
        <tbody>
        {{- range .Misconfigurations }}
          <tr class="row" data-severity="{{ escapeXML .Severity }}">
            <td class="pkg">{{ escapeXML .Title }}</td>
            <td>{{ escapeXML .ID }}</td>
            <td><span class="badge {{ escapeXML .Severity }}">{{ escapeXML .Severity }}</span></td>
            <td class="title-cell">{{ escapeXML .Message }}</td>
            <td class="links"><a href="{{ escapeXML .PrimaryURL | printf "%q" }}" target="_blank" rel="noopener">{{ escapeXML .PrimaryURL }}</a></td>
          </tr>
        {{- end }}
        </tbody>
      </table>
      {{- end }}

      </div>
    </section>
    {{- end }}

    <footer>Generated by Trivy &nbsp;•&nbsp; {{ now }}</footer>
  </div>

<script>
  (function(){
    var rows = Array.prototype.slice.call(document.querySelectorAll('tr.row'));
    var counts = {CRITICAL:0, HIGH:0, MEDIUM:0, LOW:0, UNKNOWN:0};
    rows.forEach(function(r){
      var sev = (r.getAttribute('data-severity') || 'UNKNOWN').toUpperCase();
      if (counts[sev] === undefined) sev = 'UNKNOWN';
      counts[sev]++;
    });
    Object.keys(counts).forEach(function(sev){
      var el = document.getElementById('cnt-' + sev);
      if (el) el.textContent = counts[sev];
    });

    var activeSev = 'ALL';
    var query = '';

    function applyFilters(){
      rows.forEach(function(r){
        var sev = (r.getAttribute('data-severity') || 'UNKNOWN').toUpperCase();
        var matchesSev = (activeSev === 'ALL') || (sev === activeSev);
        var matchesQuery = !query || r.textContent.toLowerCase().indexOf(query) !== -1;
        r.classList.toggle('hidden-row', !(matchesSev && matchesQuery));
      });
    }

    document.querySelectorAll('.card').forEach(function(card){
      card.addEventListener('click', function(){
        var sev = card.getAttribute('data-sev');
        activeSev = (activeSev === sev) ? 'ALL' : sev;
        document.querySelectorAll('.card').forEach(function(c){ c.classList.toggle('active', c.getAttribute('data-sev') === activeSev); });
        document.querySelectorAll('.pill').forEach(function(p){ p.classList.toggle('active', p.getAttribute('data-filter') === activeSev); });
        applyFilters();
      });
    });

    document.querySelector('.pill[data-filter="ALL"]').addEventListener('click', function(){
      activeSev = 'ALL';
      document.querySelectorAll('.card').forEach(function(c){ c.classList.remove('active'); });
      document.querySelectorAll('.pill').forEach(function(p){ p.classList.toggle('active', p === this); }.bind(this));
      this.classList.add('active');
      applyFilters();
    });

    document.getElementById('search').addEventListener('input', function(e){
      query = e.target.value.trim().toLowerCase();
      applyFilters();
    });
  })();
</script>
{{- else }}
</head>
<body>
  <div style="font-family:sans-serif; padding:40px; text-align:center; color:#16a34a; font-size:18px; font-weight:700;">
    ✓ Trivy scan returned no results — nothing to report.
  </div>
{{- end }}
</body>
</html>
