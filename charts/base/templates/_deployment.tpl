{{- define "base.deployment" -}}
{{- $root := . -}}
{{- range $deploymentName, $deploymentValuesOverride := .Values.deployments }}
{{- $deploymentValues := merge dict $deploymentValuesOverride $root -}}
{{- if $deploymentValues.enabled }}
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
  labels:
    {{- include "base.labels" $deploymentValues | nindent 4 }}
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
  {{- else if $deploymentValues.Values.argo.rollouts.enabled }}
  {{- with $deploymentValues.Values.argo.rollouts.strategy }}
  strategy:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if $deploymentValues.Values.autoscaling.enabled }}
  replicas: {{ $deploymentValues.Values.autoscaling.minReplicas }}
  {{- else }}
  replicas: {{ $deploymentValues.Values.replicaCount }}
  {{- end }}
  {{- else if not $deploymentValues.Values.autoscaling.enabled }}
  replicas: {{ $deploymentValues.Values.replicaCount }}
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
      {{- include "base.selectorLabels" $deploymentValues | nindent 6 }}
  template:
    metadata:
      {{- if or $deploymentValues.Values.prometheusScrape $deploymentValues.Values.podAnnotations }}
      annotations:
        {{- if $deploymentValues.Values.prometheusScrape }}
        prometheus.io/path: {{ $deploymentValues.Values.prometheusScrapePath | quote }}
        prometheus.io/port: {{ $deploymentValues.Values.prometheusScrapePort | quote }}
        prometheus.io/scrape: "true"
        {{- end }}
        {{- include "base.valuesPairs" $deploymentValues.Values.podAnnotations | trim | nindent 8 }}
      {{- end }}
      labels:
        {{- include "base.selectorLabels" $deploymentValues | nindent 8 }}
    spec:
      {{- with include "base.containerDefaultProperties" $deploymentValues }}
      {{- . | trim | nindent 6 }}
      {{- end }}
      {{- if $deploymentValues.Values.initContainers }}
      initContainers:
        {{- range $containerName, $containerValues := $deploymentValues.Values.initContainers }}
        - name: {{ $containerName }}
          {{- include "base.image" (merge dict $containerValues.image $deploymentValues.Values.image) | nindent 10 }}
          {{- range $key, $value := $containerValues.containerPorts }}
          ports:
            - name: {{ $key | quote }}
              containerPort: {{ $value }}
              protocol: TCP
          {{- end }}
          {{- with include "base.podDefaultProperties" $containerValues }}
          {{- . | trim | nindent 10 }}
          {{- end }}
        {{- end }}
      {{- end }}
      containers:
        {{- range $containerName, $containerValues := $deploymentValues.Values.extraContainers }}
        - name: {{ $containerName }}
          {{- include "base.image" (merge dict $containerValues.image $deploymentValues.Values.image) | nindent 10 }}
          {{- range $key, $value := $containerValues.containerPorts }}
          ports:
            - name: {{ $key | quote }}
              containerPort: {{ $value }}
              protocol: TCP
          {{- end }}
          {{- with include "base.podDefaultProperties" $containerValues }}
          {{- . | trim | nindent 10 }}
          {{- end }}
        {{- end }}
        - name: {{ include "base.name" $deploymentValues }}
          {{- include "base.image" $deploymentValues.Values.image | nindent 10 }}
          {{- if $deploymentValues.Values.containerPorts }}
          ports:
          {{- range $key, $value := $deploymentValues.Values.containerPorts }}
            - name: {{ $key | quote }}
              containerPort: {{ $value }}
              protocol: TCP
          {{- end }}
          {{- else if $deploymentValues.Values.service.ports }}
          ports:
          {{- range $key, $value := $deploymentValues.Values.service.ports }}
            - name: {{ $key | quote }}
              containerPort: {{ $value }}
              protocol: TCP
          {{- end }}
          {{- end }}
          {{- with include "base.podDefaultProperties" $deploymentValues.Values }}
          {{- . | trim | nindent 10 }}
          {{- end }}
      {{- if $deploymentValues.Values.terminationGracePeriodSeconds }}
      terminationGracePeriodSeconds: {{ $deploymentValues.Values.terminationGracePeriodSeconds }}
      {{- end }}
      {{- with include "base.volumes" $deploymentValues }}
      {{- . | trim | nindent 6 }}
      {{- end }}
{{- end }}
{{- end }}
{{- end }}