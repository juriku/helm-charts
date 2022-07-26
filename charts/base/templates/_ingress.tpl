{{- define "base.ingress" -}}
{{- if .Values.ingress.enabled -}}
{{- $fullName := include "base.fullname" . -}}
{{- $svcPort := include "base.servicePortDefaultNum" . -}}
{{- $serviceValues := .Values.service | default dict -}}
{{- $svcName := $serviceValues.name | default $fullName -}}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ $fullName }}
  labels:
    {{- include "base.commonLabels" . | trim | nindent 4 }}
  {{- with .Values.ingress.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if .Values.ingress.class }}
  ingressClassName: {{ .Values.ingress.class | quote }}
  {{- end }}
  {{- if .Values.ingress.backend }}
  defaultBackend:
    {{- if .Values.ingress.backend.resource }}
    {{- with .Values.ingress.backend.resource }}
    resource:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- else }}
    service:
      name: {{ .Values.ingress.backend.serviceName }}
      port:
        {{- if regexMatch "[0-9]" ( .Values.ingress.backend.servicePort | toString ) }}
        number: {{ .Values.ingress.backend.servicePort | default 80 }}
        {{- else }}
        name: {{ .Values.ingress.backend.servicePort }}
        {{- end }}
    {{- end }}
  {{- end }}
  tls:
  {{- if .Values.ingress.tls }}
    {{- range .Values.ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      {{- if .secretName }}
      secretName: {{ .secretName }}
      {{- end }}
    {{- end }}
  {{- else }}
    - hosts:
        {{- range .Values.ingress.hosts }}
        - {{ .host | quote }}
        {{- end }}
      {{- if .Values.tls }}
      {{- if .Values.tls.default }}
      secretName: {{ .Values.tls.default }}
      {{- end }}
      {{- end }}
  {{- end }}
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- $hostValues := . -}}
          {{- $defaultList := list (dict "a" "b") -}}
          {{- $hostPaths := .paths | default $defaultList -}}
          {{- range $hostPaths }}
          {{- $hostValues := mergeOverwrite (dict) (deepCopy $hostValues) . }}
          - path: {{ $hostValues.path | default "/" | quote }}
            pathType: {{ $hostValues.pathType | default "Prefix" }}
            backend:
              {{- if $hostValues.resource }}
              {{- with $hostValues.resource }}
              resource:
               {{- toYaml . | nindent 16 }}
              {{- end }}
              {{- else }}
              service:
                {{- if $hostValues.serviceName }}
                name: {{ $hostValues.serviceName }}
                {{- else }}
                name: {{ $svcName }}
                {{- end }}
                port:
                  {{- if $hostValues.servicePort }}
                  {{- if regexMatch "[0-9]" ( $hostValues.servicePort | toString ) }}
                  number: {{ $hostValues.servicePort }}
                  {{- else }}
                  name: {{ $hostValues.servicePort }}
                  {{- end }}
                  {{- else }}
                  number: {{ $svcPort }}
                  {{- end }}
                {{- end }}
          {{- end }}
    {{- end }}
{{- end }}
{{- end }}