{{- define "base.deployment" -}}
{{- $deploymentValues := . -}}
---
{{- if and $deploymentValues.Values.argo.rollouts.enabled ( eq $deploymentValues.Values.argo.rollouts.type "Deployment" ) }}
apiVersion: {{ $deploymentValues.Values.argo.rollouts.apiVersion }}
kind: {{ $deploymentValues.Values.argo.rollouts.kind }}
{{- else }}
apiVersion: {{ $deploymentValues.Values.apiVersion | default "apps/v1" }}
kind: {{ $deploymentValues.Values.kind | default "Deployment" }}
{{- end }}
metadata:
  name: {{ include "base.fullname" $deploymentValues }}
  {{- if $deploymentValues.Values.namespace }}
  namespace: {{ $deploymentValues.Values.namespace }}
  {{- end }}
  labels:
    {{- include "base.labels" $deploymentValues | trim | nindent 4 }}
    {{- with $deploymentValues.Values.labelsDeployment }}
    {{- toYaml . | nindent 4 }}
    {{- end }}
  {{- if $deploymentValues.Values.annotations }}
  annotations:
    {{- include "base.valuesPairs" $deploymentValues.Values.annotations | trim | nindent 4 }}
  {{- end }}
spec:
  {{- if and $deploymentValues.Values.argo.rollouts.enabled ( eq $deploymentValues.Values.argo.rollouts.type "workloadRef" ) }}
  replicas: 0
  {{- else if and (not $deploymentValues.Values.autoscaling.enabled) (not $deploymentValues.Values.keda.enabled) }}
  replicas: {{ $deploymentValues.Values.replicas }}
  {{- end }}
  revisionHistoryLimit: {{ $deploymentValues.Values.revisionHistoryLimit | default 10 }}
  {{- if $deploymentValues.Values.argo.rollouts.enabled }}
  {{- with $deploymentValues.Values.argo.rollouts.strategy }}
  strategy:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- else }}
  {{- with $deploymentValues.Values.strategy }}
  strategy:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- end }}
  {{- if $deploymentValues.Values.minReadySeconds }}
  minReadySeconds: {{ $deploymentValues.Values.minReadySeconds }}
  {{- end }}
  {{- if $deploymentValues.Values.progressDeadlineSeconds }}
  progressDeadlineSeconds: {{ $deploymentValues.Values.progressDeadlineSeconds }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "base.selectorLabels" $deploymentValues | trim | nindent 6 }}
  template:
    metadata:
      {{- if or $deploymentValues.Values.prometheusScrape $deploymentValues.Values.podAnnotations }}
      annotations:
        {{- if $deploymentValues.Values.prometheusScrape }}
        prometheus.io/path: {{ $deploymentValues.Values.prometheusScrapePath | quote }}
        prometheus.io/port: {{ $deploymentValues.Values.prometheusScrapePort | quote }}
        prometheus.io/scrape: "true"
        {{- end }}
        {{- if $deploymentValues.Values.podAnnotations }}
        {{- include "base.valuesPairs" $deploymentValues.Values.podAnnotations | trim | nindent 8 }}
        {{- end }}
      {{- end }}
      labels:
        {{- with $deploymentValues.Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
        {{- include "base.selectorLabels" $deploymentValues | trim | nindent 8 }}
    spec:
      {{- with include "base.podDefaultProperties" $deploymentValues }}
      {{- . | trim | nindent 6 }}
      {{- end }}
      {{- if $deploymentValues.Values.initContainers }}
      initContainers:
        {{- range $containerName, $containerValues := $deploymentValues.Values.initContainers }}
        - name: {{ $containerName }}
          {{- include "base.image" (merge dict $containerValues.image $deploymentValues.Values.image) | nindent 10 }}
          {{- with $containerValues.ports }}
          ports:
            {{- toYaml . | trim | nindent 12 }}
          {{- end }}
          {{- with include "base.containerDefaultProperties" $containerValues }}
          {{- . | trim | nindent 10 }}
          {{- end }}
        {{- end }}
      {{- end }}
      containers:
        - name: {{ include "base.name" $deploymentValues }}
          {{- include "base.image" $deploymentValues.Values.image | nindent 10 }}
          {{- with $deploymentValues.Values.ports }}
          ports:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with include "base.containerDefaultProperties" $deploymentValues.Values }}
          {{- . | trim | nindent 10 }}
          {{- end }}
        {{- range $containerName, $containerValues := $deploymentValues.Values.extraContainers }}
        - name: {{ $containerName }}
          {{- include "base.image" (merge dict $containerValues.image $deploymentValues.Values.image) | nindent 10 }}
          {{- with $containerValues.ports }}
          ports:
            {{- toYaml . | trim | nindent 12 }}
          {{- end }}
          {{- with include "base.containerDefaultProperties" $containerValues }}
          {{- . | trim | nindent 10 }}
          {{- end }}
        {{- end }}
      {{- with include "base.volumes" $deploymentValues }}
      {{- . | trim | nindent 6 }}
      {{- end }}
{{- end }}