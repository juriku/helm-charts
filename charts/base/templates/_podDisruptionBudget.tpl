{{- define "base.podDisruptionBudget" -}}
{{- if .Values.podDisruptionBudget.enabled }}
{{- $autoscaling := .Values.autoscaling | default dict -}}
---
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
  name: {{ include "base.fullname" . }}
spec:
  {{- if .Values.podDisruptionBudget.minAvailable }}
  minAvailable: {{ .Values.podDisruptionBudget.minAvailable }}
  {{- else if and $autoscaling.enabled $autoscaling.minReplicas }}
  minAvailable: {{ $autoscaling.minReplicas }}
  {{- else }}
  minAvailable: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "base.selectorLabels" . | nindent 6 }}
{{- end }}
{{- end }}