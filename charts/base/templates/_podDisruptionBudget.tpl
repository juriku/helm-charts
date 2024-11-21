{{- define "base.podDisruptionBudget" -}}
{{- if .Values.podDisruptionBudget.enabled }}
{{- $autoscaling := .Values.autoscaling | default dict -}}
---
apiVersion: {{ .Values.podDisruptionBudget.apiVersion | default "policy/v1" }}
kind: PodDisruptionBudget
metadata:
  name: {{ include "base.fullname" . }}
  labels:
    {{- include "base.labels" . | trim | nindent 4 }}
spec:
  {{- if .Values.podDisruptionBudget.minAvailable }}
  minAvailable: {{ .Values.podDisruptionBudget.minAvailable }}
  {{- else if and .Values.keda.enabled }}
  minAvailable: {{ if (lt (int .Values.keda.minReplicaCount) 2) }}1{{else}}{{ div .Values.keda.minReplicaCount 2 }}{{end}}
  {{- else if and .Values.autoscaling.enabled .Values.autoscaling.minReplicas }}
  minAvailable: {{ if (lt (int .Values.autoscaling.minReplicas) 2) }}1{{else}}{{ div .Values.autoscaling.minReplicas 2 }}{{end}}
  {{- else }}
  minAvailable: {{ if (lt (int .Values.replicas) 2) }}1{{else}}{{ div .Values.replicas 2 }}{{end}}
  {{- end }}
  {{- if .Values.podDisruptionBudget.maxUnavailable }}
  maxUnavailable: {{ .Values.podDisruptionBudget.maxUnavailable }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "base.selectorLabels" . | trim | nindent 6 }}
{{- end }}
{{- end }}