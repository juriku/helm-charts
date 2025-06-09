{{- define "base.keda" -}}
{{- if .Values.keda.enabled }}
{{- $labels := include "base.labels" . }}
{{- $keda := .Values.keda }}
---
apiVersion: {{ .Values.keda.apiVersion | default "keda.sh/v1alpha1" }}
kind: ScaledObject
metadata:
  name: {{ include "base.fullname" . }}
  {{- if .Values.keda.namespace }}
  namespace: {{ .Values.keda.namespace }}
  {{- else if .Values.namespace }}
  namespace: {{ .Values.namespace }}
  {{- end }}
  labels:
    {{- $labels | trim | nindent 4 }}
  {{- with .Values.keda.annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  scaleTargetRef:
    {{- if .Values.argo.rollouts.enabled }}
    apiVersion: {{ coalesce .Values.keda.scaleTargetRef.apiVersion .Values.argo.rollouts.apiVersion }}
    kind: {{ coalesce .Values.keda.scaleTargetRef.kind .Values.argo.rollouts.kind }}
    {{- else }}
    apiVersion: {{ coalesce .Values.keda.scaleTargetRef.apiVersion .Values.apiVersion "apps/v1" }}
    kind: {{ coalesce .Values.keda.scaleTargetRef.kind .Values.kind "Deployment" }}
    {{- end }}
    name: {{ .Values.keda.scaleTargetRef.name | default (include "base.fullname" .) }}
    {{- if .Values.keda.scaleTargetRef.envSourceContainerName }}
    envSourceContainerName: {{ .Values.keda.scaleTargetRef.envSourceContainerName }}
    {{- end }}
  pollingInterval: {{ .Values.keda.pollingInterval | default 30 }}
  cooldownPeriod: {{ .Values.keda.cooldownPeriod | default 300 }}
  {{- if .Values.keda.idleReplicaCount }}
  idleReplicaCount: {{ .Values.keda.idleReplicaCount }}
  {{- end }}
  minReplicaCount:  {{ .Values.keda.minReplicaCount | default 0 }}
  maxReplicaCount:  {{ .Values.keda.maxReplicaCount | default 100 }}
  {{- with .Values.keda.fallback }}
  fallback:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.keda.advanced }}
  advanced:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with .Values.keda.triggers }}
  triggers:
    {{- toYaml . | nindent 4 }}
  {{- end }}

{{- if or .Values.keda.TriggerAuthentication .Values.keda.ClusterTriggerAuthentication }}
{{- range .Values.keda.TriggerAuthentication }}
---
apiVersion: {{ $keda.apiVersion | default "keda.sh/v1alpha1" }}
kind: TriggerAuthentication
metadata:
  name: {{ .name }}
  {{- with .labels }}
  labels:
    {{- $labels | trim | nindent 4 }}
  {{- end }}
  {{- with .annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- with .spec }}
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- range .Values.keda.ClusterTriggerAuthentication }}
---
apiVersion: {{ $keda.apiVersion | default "keda.sh/v1alpha1" }}
kind: ClusterTriggerAuthentication
metadata:
  name: {{ .name }}
  {{- with .labels }}
  labels:
    {{- $labels | trim | nindent 4 }}
  {{- end }}
  {{- with .annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
spec:
  {{- with .spec }}
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end }}
{{- end }}

{{- end }}
{{- end }}