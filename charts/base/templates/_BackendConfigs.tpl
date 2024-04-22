{{- define "base.backendConfigs" -}}
{{- if .Values.backendConfigs }}
{{- $root := . -}}
{{- range .Values.backendConfigs }}
---
apiVersion: cloud.google.com/v1
kind: BackendConfig
metadata:
  name: {{ .name }}
  {{- if .namespace }}
  namespace: {{ .namespace }}
  {{- end }}
  labels:
    {{- include "base.labels" $root | trim | nindent 4 }}
spec:
{{- with .spec }}
{{ toYaml . | indent 2 }}
{{- end }}
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
{{- with .customRequestHeaders }}
  customRequestHeaders:
    {{- toYaml . | nindent 4 }}
{{- end }}
{{- with .customResponseHeaders }}
  customResponseHeaders:
    {{- toYaml . | nindent 4 }}
{{- end }}
{{- end }}
{{- end }}
{{- if .Values.frontendConfigs }}
{{- $root := . -}}
{{- range .Values.frontendConfigs }}
---
apiVersion: networking.gke.io/v1beta1
kind: FrontendConfig
metadata:
  name: {{ .name }}
  {{- if .namespace }}
  namespace: {{ .namespace }}
  {{- end }}
  labels:
    {{- include "base.labels" $root | trim | nindent 4 }}
spec:
{{- with .spec }}
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}