{{- define "base.podDisruptionBudget" -}}
{{- if .Values.podDisruptionBudget.enabled }}
---
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
  name: {{ include "base.fullname" . }}
spec:
  {{- if .Values.podDisruptionBudget.minAvailable }}
  minAvailable: {{ .Values.podDisruptionBudget.minAvailable }}
  {{- else if .Values.autoscaling.enabled }}
  minAvailable: {{ .Values.autoscaling.minReplicas }}
  {{- else }}
  minAvailable: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "base.selectorLabels" . | nindent 6 }}
{{- end }}
{{- end }}