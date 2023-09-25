{{- define "base.ingress" -}}
{{- $root := . -}}
{{- $fullName := include "base.fullname" . -}}
{{- $svcPort := include "base.servicePortDefaultNum" . -}}
{{- $serviceValues := .Values.service | default dict -}}
{{- $svcName := $serviceValues.name | default $fullName -}}
{{- $ingressMap := list -}}
{{- $defaultIngressValues := .Values.ingress -}}
{{- if $defaultIngressValues.enabled -}}
{{- $ingressMap = list $defaultIngressValues -}}
{{- end -}}
{{- if .Values.ingressList -}}
{{- range $item  := .Values.ingressList -}}
{{- $ingressMap = append $ingressMap $item -}}
{{- end -}}
{{- end -}}
{{- range $index, $ingressValues := $ingressMap }}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  {{- if $ingressValues.name }}
  name: {{ $ingressValues.name }}
  {{- else }}
  {{- if eq $index 0 }}
  name: {{ $fullName }}
  {{- else }}
  name: {{ printf "%s-%s" $fullName (toString (add $index 1)) }}
  {{- end }}
  {{- end }}
  labels:
    {{- include "base.commonLabels" $root | trim | nindent 4 }}
    {{- with $ingressValues.labels }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- with $ingressValues.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- if $ingressValues.class }}
  ingressClassName: {{ $ingressValues.class | quote }}
  {{- else if $defaultIngressValues.class }}
  ingressClassName: {{ $defaultIngressValues.class | quote }}
  {{- end }}
  {{- if $ingressValues.backend }}
  defaultBackend:
    {{- if $ingressValues.backend.resource }}
    {{- with $ingressValues.backend.resource }}
    resource:
      {{- toYaml . | nindent 6 }}
    {{- end }}
    {{- else }}
    service:
      name: {{ $ingressValues.backend.serviceName }}
      port:
        {{- if regexMatch "[0-9]" ( $ingressValues.backend.servicePort | toString ) }}
        number: {{ $ingressValues.backend.servicePort | default 80 }}
        {{- else }}
        name: {{ $ingressValues.backend.servicePort }}
        {{- end }}
    {{- end }}
  {{- end }}
  tls:
  {{- if $ingressValues.tls }}
    {{- range $ingressValues.tls }}
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
        {{- range $ingressValues.hosts }}
        - {{ .host | quote }}
        {{- end }}
      {{- if $root.Values.tls }}
      {{- if $root.Values.tls.default }}
      secretName: {{ $root.Values.tls.default }}
      {{- end }}
      {{- end }}
  {{- end }}
  rules:
    {{- range $ingressValues.hosts }}
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