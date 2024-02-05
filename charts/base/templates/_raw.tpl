{{- define "base.raw" -}}
{{- $template := fromYaml (include "raw.resource" .) -}}
{{- range .Values.rawYamlList }}
---
{{ toYaml (merge . $template) -}}
{{- end }}
{{- range $i, $t := .Values.rawTemplateList }}
---
{{ toYaml (merge (tpl $t $ | fromYaml) $template) -}}
{{- end }}
{{- end }}