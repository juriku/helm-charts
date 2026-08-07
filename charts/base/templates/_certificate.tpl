{{- define "base.certificates" -}}
{{- $root := . }}
{{- range $index, $cert := .Values.certificates }}
---
apiVersion: {{ $cert.apiVersion | default "cert-manager.io/v1" }}
kind: Certificate
metadata:
  {{- if $cert.name }}
  name: {{ $cert.name }}
  {{- else if eq $index 0 }}
  name: {{ include "base.fullname" $root }}
  {{- else }}
  name: {{ printf "%s-%s" (include "base.fullname" $root) (toString (add $index 1)) }}
  {{- end }}
  {{- if $cert.namespace }}
  namespace: {{ $cert.namespace }}
  {{- else if $root.Values.namespace }}
  namespace: {{ $root.Values.namespace }}
  {{- end }}
  labels:
    {{- include "base.commonLabels" $root | trim | nindent 4 }}
    {{- with $cert.labels }}
    {{- toYaml . | trim | nindent 4 }}
    {{- end }}
  {{- with $cert.annotations }}
  annotations:
    {{- toYaml . | trim | nindent 4 }}
  {{- end }}
spec:
  secretName: {{ $cert.secretName | default (printf "%s-tls" (include "base.fullname" $root)) }}
  {{- with $cert.commonName }}
  commonName: {{ . }}
  {{- end }}
  {{- with $cert.dnsNames }}
  dnsNames:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $cert.duration }}
  duration: {{ . }}
  {{- end }}
  {{- with $cert.renewBefore }}
  renewBefore: {{ . }}
  {{- end }}
  {{- with $cert.usages }}
  usages:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $cert.privateKey }}
  privateKey:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $cert.subject }}
  subject:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  issuerRef:
    name: {{ $cert.issuerRef.name }}
    kind: {{ $cert.issuerRef.kind | default "ClusterIssuer" }}
    group: {{ $cert.issuerRef.group | default "cert-manager.io" }}
{{- end }}
{{- end }}
