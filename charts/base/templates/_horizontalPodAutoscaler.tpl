{{- define "base.horizontalPodAutoscaler" -}}
{{- if .Values.autoscaling.enabled }}
---
{{- if or .Values.autoscaling.targetCPUUtilizationPercentage .Values.autoscaling.targetMemoryUtilizationPercentage }}
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
{{- else }}
apiVersion: autoscaling/v2beta2
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
  {{- range .Values.autoscaling.cpu }}
    - type: Resource
      resource:
        name: cpu
        target:
          type: {{ .type | default "Utilization" | quote }}
          averageUtilization: {{ .averageUtilization | default 50 }}
  {{- end }}
  {{- range .Values.autoscaling.memory }}
    - type: Resource
      resource:
        name: cpu
        target:
          type: {{ .type | default "Utilization" | quote  }}
          averageUtilization: {{ .averageUtilization | default 50 }}
  {{- end }}
  {{- range .Values.autoscaling.pubsub_subscription }}
    - type: External
      external:
        metric:
         name: pubsub.googleapis.com|subscription|{{ .metric | default "num_undelivered_messages" }}
         selector:
           matchLabels:
             resource.labels.subscription_id: {{ .subscription_id | quote }}
        target:
          type: {{ .type | default "AverageValue" | quote  }}
          averageValue: {{ .AverageValue | default 100 }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}