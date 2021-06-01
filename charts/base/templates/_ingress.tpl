{{- define "base.ingress" -}}
{{- if .Values.ingress.enabled -}}
{{- $fullName := include "base.fullname" . -}}
{{- $svcPort := include "base.servicePortDefault" . -}}
{{- $serviceValues := .Values.service | default dict -}}
{{- $svcName := $serviceValues.name | default $fullName -}}
---
{{- if semverCompare ">=1.19-0" .Capabilities.KubeVersion.GitVersion -}}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ $fullName }}
  labels:
    {{- include "base.labels" . | nindent 4 }}
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
    service:
      name: {{ .Values.ingress.backend.serviceName }}
      port:
        number: {{ .Values.ingress.backend.servicePort | default 80 }}
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
          {{- if .paths }}
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType | default "Prefix" }}
            backend:
              service:
                {{- if .serviceName }}
                name: {{ .serviceName | quote }}
                {{- else }}
                name: {{ $svcName }}
                {{- end }}
                port:
                  {{- if .servicePort }}
                  {{- if regexMatch "[0-9]" ( .servicePort | toString ) }}
                  number: {{ .servicePort }}
                  {{- else }}
                  name: {{ .servicePort }}
                  {{- end }}
                  {{- else }}
                  name: {{ $svcPort }}
                  {{- end }}
                {{- end }}
          {{- else }}
          - path: "/"
            pathType: Prefix
            backend:
              service:
                {{- if .serviceName }}
                name: {{ .serviceName | quote }}
                {{- else }}
                name: {{ $svcName }}
                {{- end }}
                port:
                  {{- if .servicePort }}
                  {{- if regexMatch "[0-9]" ( .servicePort | toString ) }}
                  number: {{ .servicePort }}
                  {{- else }}
                  name: {{ .servicePort }}
                  {{- end }}
                  {{- else }}
                  name: {{ $svcPort }}
                  {{- end }}
          {{- end }}
    {{- end }}
{{- else -}}
{{- if semverCompare ">=1.14-0" .Capabilities.KubeVersion.GitVersion -}}
apiVersion: networking.k8s.io/v1beta1
{{- else -}}
apiVersion: extensions/v1beta1
{{- end }}
kind: Ingress
metadata:
  name: {{ $fullName }}
  labels:
    {{- include "base.labels" . | nindent 4 }}
  annotations:
    kubernetes.io/ingress.class: {{ .Values.ingress.class | quote }}
    {{- with .Values.ingress.annotations }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
spec:
  {{- if .Values.ingress.backend }}
  backend:
    serviceName: {{ .Values.ingress.backend.serviceName }}
    servicePort: {{ .Values.ingress.backend.servicePort | default 80 }}
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
          {{- if .paths }}
          {{- range .paths }}
          - path: {{ .path }}
            backend:
              {{- if .serviceName }}
              serviceName: {{ .serviceName | quote }}
              {{- else }}
              serviceName: {{ $svcName }}
              {{- end }}
              {{- if .servicePort }}
              servicePort: {{ .servicePort }}
              {{- else }}
              servicePort: {{ $svcPort }}
              {{- end }}
              {{- end }}
          {{- else }}
          - backend:
              {{- if .serviceName }}
              serviceName: {{ .serviceName | quote }}
              {{- else }}
              serviceName: {{ $svcName }}
              {{- end }}
              {{- if .servicePort }}
              servicePort: {{ .servicePort }}
              {{- else }}
              servicePort: {{ $svcPort }}
              {{- end }}
              {{- end }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}
