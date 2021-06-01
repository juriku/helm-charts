{{- define "base.horizontalPodAutoscaler" -}}
{{- if .Values.autoscaling.enabled }}
---
apiVersion: autoscaling/v2beta1
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "base.fullname" . }}
  labels:
    {{- include "base.labels" . | nindent 4 }}
spec:
  scaleTargetRef:
    {{- if and .Values.argo.rollouts.enabled }}
    apiVersion: {{ .Values.argo.rollouts.apiVersion }}
    kind: {{ .Values.argo.rollouts.kind }}
    {{- else }}
    apiVersion: {{ .Values.apiVersion | default "apps/v1" }}
    kind: {{ .Values.kind | default "Deployment" }}
    {{- end }}
    name: {{ include "base.fullname" . }}
  minReplicas: {{ .Values.autoscaling.minReplicas }}
  maxReplicas: {{ .Values.autoscaling.maxReplicas }}
  metrics:
  {{- if .Values.autoscaling.targetCPUUtilizationPercentage }}
    - type: Resource
      resource:
        name: cpu
        targetAverageUtilization: {{ .Values.autoscaling.targetCPUUtilizationPercentage }}
  {{- end }}
  {{- if .Values.autoscaling.targetMemoryUtilizationPercentage }}
    - type: Resource
      resource:
        name: memory
        targetAverageUtilization: {{ .Values.autoscaling.targetMemoryUtilizationPercentage }}
  {{- end }}
{{- end }}
{{- end }}
