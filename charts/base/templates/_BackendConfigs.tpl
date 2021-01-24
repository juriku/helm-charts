{{- define "base.backendConfigs" -}}
{{- if .Values.backendConfigs }}
{{- range .Values.backendConfigs }}
---
apiVersion: cloud.google.com/v1
kind: BackendConfig
metadata:
  name: {{ .name }}
spec:
{{- if .iap }}
  iap:
    enabled: {{ .iap.enabled | default "true" }}
    oauthclientCredentials:
      secretName: {{ .iap.secretName }}
{{- end }}
{{- if .securityPolicy }}
  securityPolicy:
    name: {{ .securityPolicy }}
{{- end }}
{{- if .timeoutSec }}
  timeoutSec: {{ .timeoutSec }}
{{- end }}
{{- if .drainingTimeoutSec }}
  connectionDraining:
    drainingTimeoutSec: {{ .drainingTimeoutSec }}
{{- end }}
{{- if .affinityType }}
  sessionAffinity:
    affinityType: {{ .affinityType }}
    {{- if .affinityCookieTtlSec }}
    affinityCookieTtlSec: {{ .affinityCookieTtlSec }}
    {{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}