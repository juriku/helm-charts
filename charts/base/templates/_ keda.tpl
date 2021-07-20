{{- define "base.keda" -}}
{{- if .Values.keda.enabled }}
{{- $root := . -}}
---
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: {{ include "base.fullname" . }}
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
    {{- if .Values.keda.envSourceContainerName }}
    envSourceContainerName: {{ .Values.keda.envSourceContainerName | quote }}
    {{- end }}
  pollingInterval: {{ .Values.keda.pollingInterval | default "30" }}
  cooldownPeriod: {{ .Values.keda.cooldownPeriod | default "300" }}
  minReplicaCount: {{ .Values.keda.minReplicaCount | default "2" }}
  maxReplicaCount: {{ .Values.keda.maxReplicaCount | default "10" }}
  {{- with .Values.keda.advanced }}
  advanced:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  triggers:
  {{- with .Values.keda.triggers }}
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- if .Values.keda.secretTargetRef }}
---
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: {{ include "base.fullname" . }}
spec:
  secretTargetRef:
  {{- range .Values.keda.secretTargetRef }}
  - parameter: {{ .parameter | default "GoogleApplicationCredentials" | quote }} 
    name: {{ .name | quote }}
    key: {{ .key | default "GOOGLE_APPLICATION_CREDENTIALS" | quote }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}