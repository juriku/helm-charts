{{- define "base.flagger" -}}
{{- if .Values.flagger }}
---
apiVersion: {{ .Values.flagger.apiVersion | default "flagger.app/v1beta1" }}
kind: Canary
metadata:
  {{- if .Values.flagger.name }}
  name: {{ .Values.flagger.name }}
  {{- else }}
  name: {{ include "base.fullname" . }}
  {{- end }}
spec:
  {{- with .Values.flagger.ingressRef }}
  ingressRef:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  targetRef:
    apiVersion: {{ .Values.apiVersion | default "apps/v1" }}
    kind: Deployment
    name: {{ include "base.fullname" . }}
  {{- if .Values.autoscaling.enabled }}
  autoscalerRef:
    apiVersion: autoscaling/v2beta1
    kind: HorizontalPodAutoscaler
    name: {{ include "base.fullname" . }}
  {{- end }}
  {{- if .Values.flagger.progressDeadlineSeconds }}
  progressDeadlineSeconds: {{ .Values.flagger.progressDeadlineSeconds }}
  {{- end }}
  service:
  {{- if .Values.flagger.service }}
  {{- with .Values.flagger.service }}
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- else }}
    portName: {{ include "base.servicePortDefault" . }}
    port: {{ include "base.servicePortDefaultNum" . }}
    {{- if .Values.containerPorts }}
    {{- if .Values.containerPorts.http }}
    targetPort: {{ .Values.containerPorts.http }}
    {{- else }}
    targetPort: {{- values .Values.containerPorts | first }}
    {{- end }}
    {{- end }}
  {{- end }}
  {{- with .Values.flagger.analysis }}
  analysis:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}