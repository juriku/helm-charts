{{- define "base.service" -}}
{{- if .Values.service.enabled }}
---
apiVersion: v1
kind: Service
metadata:
  {{- if .Values.service.name }}
  name: {{ .Values.service.name }}
  {{- else }}
  name: {{ include "base.fullname" . }}
  {{- end }}
  labels:
    {{- include "base.labels" . | nindent 4 }}
  {{- with .Values.service.labels }}
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.service.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  type: {{ .Values.service.type }}
  {{- if .Values.service.externalTrafficPolicy }}
  externalTrafficPolicy: {{ .Values.service.externalTrafficPolicy }}
  {{- end }}
  {{- if .Values.service.loadBalancerIP }}
  loadBalancerIP: {{ .Values.service.loadBalancerIP | quote }}
  {{- end }}
  ports:
  {{- if .Values.service.ports }}
  {{- range $key, $value := .Values.service.ports }}
    - port: {{ $value }}
      targetPort: {{ $key | quote }}
      protocol: TCP
      name: {{ $key | quote }}
  {{- end }}
  {{- else if .Values.containerPorts }}
  {{- range $key, $value := .Values.containerPorts }}
    - port: {{ $value }}
      targetPort: {{ $key | quote }}
      protocol: TCP
      name: {{ $key | quote }}
  {{- end }}
  {{- else }}
    - port: 80
      targetPort: "http"
      protocol: TCP
      name: "http"
  {{- end }}
  selector:
    {{- include "base.selectorLabels" . | nindent 4 }}
{{- end }}
{{- end }}