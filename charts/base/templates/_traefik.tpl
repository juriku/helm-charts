{{- define "base.traefikMiddlewares" -}}
{{- $root := . }}
{{- range $name, $middleware := .Values.traefikMiddlewares }}
---
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: {{ printf "%s-%s" (include "base.fullname" $root) $name }}
  {{- if $root.Values.namespace }}
  namespace: {{ $root.Values.namespace }}
  {{- end }}
  labels:
    {{- include "base.commonLabels" $root | trim | nindent 4 }}
spec:
  {{- toYaml $middleware | nindent 2 }}
{{- end }}
{{- end }}

{{- define "base.traefikIngressRoutes" -}}
{{- $root := . }}
{{- range $index, $route := .Values.traefikIngressRoutes }}
---
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  {{- if $route.name }}
  name: {{ $route.name }}
  {{- else if eq $index 0 }}
  name: {{ include "base.fullname" $root }}
  {{- else }}
  name: {{ printf "%s-%s" (include "base.fullname" $root) (toString (add $index 1)) }}
  {{- end }}
  {{- if $route.namespace }}
  namespace: {{ $route.namespace }}
  {{- else if $root.Values.namespace }}
  namespace: {{ $root.Values.namespace }}
  {{- end }}
  labels:
    {{- include "base.commonLabels" $root | trim | nindent 4 }}
    {{- with $route.labels }}
    {{- toYaml . | trim | nindent 4 }}
    {{- end }}
  {{- with $route.annotations }}
  annotations:
    {{- toYaml . | trim | nindent 4 }}
  {{- end }}
spec:
  entryPoints:
    {{- toYaml ($route.entryPoints | default (list "websecure")) | nindent 4 }}
  routes:
    {{- range $route.routes }}
    - kind: {{ .kind | default "Rule" }}
      match: {{ .match | quote }}
      {{- with .priority }}
      priority: {{ . }}
      {{- end }}
      {{- with .middlewares }}
      middlewares:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      services:
        {{- if .services }}
        {{- toYaml .services | nindent 8 }}
        {{- else }}
        - name: {{ $root.Values.service.name | default (include "base.fullname" $root) }}
          port: {{ include "base.servicePortDefaultNum" $root }}
        {{- end }}
    {{- end }}
  {{- with $route.tls }}
  tls:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}
