{{- define "base.horizontalPodAutoscaler" -}}
{{- if .Values.autoscaling.enabled }}
{{- $deploymentValues := . -}}
---
apiVersion: {{ .Values.autoscaling.apiVersion | default "autoscaling/v2" }}
kind: HorizontalPodAutoscaler
metadata:
  name: {{ include "base.fullname" . }}
  labels:
    {{- include "base.labels" . | trim | nindent 4 }}
spec:
  scaleTargetRef:
    {{- if .Values.argo.rollouts.enabled }}
    apiVersion: {{ .Values.argo.rollouts.apiVersion }}
    kind: {{ .Values.argo.rollouts.kind }}
    {{- else }}
    apiVersion: {{ .Values.apiVersion | default "apps/v1" }}
    kind: {{ .Values.kind | default "Deployment" }}
    {{- end }}
    name: {{ include "base.fullname" . }}
  {{- if .Values.autoscaling.minReplicas }}
  minReplicas: {{ .Values.autoscaling.minReplicas }}
  {{- end }}
  maxReplicas: {{ .Values.autoscaling.maxReplicas }}
  metrics:
  {{- range .Values.autoscaling.memory }}
    - type: Resource
      resource:
        name: memory
        target:
          type: {{ .type | default "Utilization" | quote  }}
          averageUtilization: {{ .averageUtilization | default 50 }}
  {{- end }}
  {{- range .Values.autoscaling.cpu }}
    - type: Resource
      resource:
        name: cpu
        target:
          type: {{ .type | default "Utilization" | quote }}
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
  {{- range .Values.autoscaling.ingress_requests }}
    - type: Object
      object:
        metric:
          name: {{ .name | default "requests-per-second" }}
        describedObject:
          apiVersion: networking.k8s.io/v1
          kind: Ingress
          name: {{ .ingress_name | default (include "base.fullname" $deploymentValues) }}
        target:
          type: Value
          value: {{ .AverageValue | default "10k" }}
  {{- end }}
  {{- with .Values.autoscaling.metrics }}
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.autoscaling.behavior }}
  behavior:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}