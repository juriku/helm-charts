{{- define "base.deployment" -}}
{{- if not .Values.statefulSet }}
{{- $root := . -}}
---
{{- if and $root.Values.argo.rollouts.enabled ( eq $root.Values.argo.rollouts.type "Deployment" ) }}
apiVersion: {{ $root.Values.argo.rollouts.apiVersion }}
kind: {{ $root.Values.argo.rollouts.kind }}
{{- else }}
apiVersion: apps/v1
kind: {{ include "base.kind" . }}
{{- end }}
metadata:
  name: {{ include "base.fullname" $root }}
  {{- if $root.Values.namespace }}
  namespace: {{ $root.Values.namespace }}
  {{- end }}
  labels:
    {{- include "base.labels" $root | trim | nindent 4 }}
    {{- with $root.Values.labelsDeployment }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- if $root.Values.annotations }}
  annotations:
    {{- include "base.valuesPairs" $root.Values.annotations | trim | nindent 4 }}
  {{- end }}
spec:
  {{- if and $root.Values.argo.rollouts.enabled ( eq $root.Values.argo.rollouts.type "workloadRef" ) }}
  replicas: 0
  {{- else if and (not $root.Values.autoscaling.enabled) (not $root.Values.keda.enabled) }}
  replicas: {{ $root.Values.replicas }}
  {{- end }}
  revisionHistoryLimit: {{ $root.Values.revisionHistoryLimit | default 10 }}
  {{- if $root.Values.argo.rollouts.enabled }}
  {{- with $root.Values.argo.rollouts.strategy }}
  strategy:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- else }}
  {{- with $root.Values.strategy }}
  strategy:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- end }}
  {{- if $root.Values.minReadySeconds }}
  minReadySeconds: {{ $root.Values.minReadySeconds }}
  {{- end }}
  {{- if $root.Values.progressDeadlineSeconds }}
  progressDeadlineSeconds: {{ $root.Values.progressDeadlineSeconds }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "base.selectorLabels" $root | trim | nindent 6 }}
  template:
    metadata:
      {{- $checksums := include "base.configChecksums" $root }}
      {{- if or $root.Values.prometheusScrape $root.Values.podAnnotations $checksums }}
      annotations:
        {{- with $checksums }}
        {{- . | trim | nindent 8 }}
        {{- end }}
        {{- if $root.Values.prometheusScrape }}
        prometheus.io/path: {{ $root.Values.prometheusScrapePath | quote }}
        prometheus.io/port: {{ $root.Values.prometheusScrapePort | quote }}
        prometheus.io/scrape: "true"
        {{- end }}
        {{- if $root.Values.podAnnotations }}
        {{- include "base.valuesPairs" $root.Values.podAnnotations | trim | nindent 8 }}
        {{- end }}
      {{- end }}
      labels:
        {{- with $root.Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- include "base.selectorLabels" $root | trim | nindent 8 }}
    spec:
      {{- with include "base.podDefaultProperties" $root }}
      {{- . | trim | nindent 6 }}
      {{- end }}
      {{- with include "base.initContainers" $root }}
      {{- . | trim | nindent 6 }}
      {{- end }}
      {{- include "base.containers" $root | trim | nindent 6 }}
      {{- with include "base.volumes" $root }}
      {{- . | trim | nindent 6 }}
      {{- end }}
{{- end }}
{{- end }}