{{- define "base.verticalPodAutoscaler" -}}
{{- if .Values.verticalPodAutoscaler.enabled }}
---
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: {{ include "base.fullname" . }}
  labels:
    {{- include "base.labels" . | trim | nindent 4 }}
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: {{ include "base.fullname" . }}
  updatePolicy:
    updateMode: {{ .Values.verticalPodAutoscaler.updateMode | quote }}
{{- end }}
{{- end }}