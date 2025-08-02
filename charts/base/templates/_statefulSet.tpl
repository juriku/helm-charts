{{- define "base.statefulSet" -}}
{{- if .Values.statefulSet }}
{{- $root := . -}}
---
apiVersion: {{ $root.Values.apiVersion | default "apps/v1" }}
kind: {{ include "base.kind" . }}
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
  {{- if and (not $root.Values.autoscaling.enabled) (not $root.Values.keda.enabled) }}
  replicas: {{ $root.Values.replicas }}
  {{- end }}
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      {{- include "base.selectorLabels" $root | trim | nindent 8 }}
  {{- if $root.Values.serviceName }}
  serviceName: {{ $root.Values.serviceName }}
  {{- end }}
  {{- with $root.Values.strategy }}
  updateStrategy:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  template:
    metadata:
      labels:
        {{- include "base.labels" $root | trim | nindent 8 }}
        {{- with $root.Values.podLabels }}
        {{- toYaml . | nindent 8 }}
        {{- end }}
      {{- if or $root.Values.prometheusScrape $root.Values.podAnnotations }}
      annotations:
        {{- if $root.Values.prometheusScrape }}
        prometheus.io/path: {{ $root.Values.prometheusScrapePath | quote }}
        prometheus.io/port: {{ $root.Values.prometheusScrapePort | quote }}
        prometheus.io/scrape: "true"
        {{- end }}
        {{- if $root.Values.podAnnotations }}
        {{- include "base.valuesPairs" $root.Values.podAnnotations | trim | nindent 8 }}
        {{- end }}
      {{- end }}
    spec:
      {{- with include "base.podDefaultProperties" $root }}
      {{- . | trim | nindent 6 }}
      {{- end }}
      {{- if $root.Values.initContainers }}
      initContainers:
        {{- range $containerName, $containerValues := $root.Values.initContainers }}
        - name: {{ $containerName }}
          {{- include "base.image" (merge dict $containerValues.image $root.Values.image) | nindent 10 }}
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
        - name: {{ include "base.name" $root }}
          {{- include "base.image" $root.Values.image | nindent 10 }}
          {{- with $root.Values.ports }}
          ports:
            {{- toYaml . | nindent 12 }}
          {{- end }}
          {{- with include "base.containerDefaultProperties" $root.Values }}
          {{- . | trim | nindent 10 }}
          {{- end }}
        {{- range $containerName, $containerValues := $root.Values.extraContainers }}
        - name: {{ $containerName }}
          {{- include "base.image" (merge dict $containerValues.image $root.Values.image) | nindent 10 }}
          {{- with $containerValues.ports }}
          ports:
            {{- toYaml . | trim | nindent 12 }}
          {{- end }}
          {{- with include "base.containerDefaultProperties" $containerValues }}
          {{- . | trim | nindent 10 }}
          {{- end }}
        {{- end }}
      {{- with include "base.volumes" $root }}
      {{- . | trim | nindent 6 }}
      {{- end }}
  {{- if $root.Values.volumeClaimTemplates }}
  persistentVolumeClaimRetentionPolicy:
    whenDeleted: {{ $root.Values.persistentVolumeClaimRetentionPolicy.whenDeleted | default "Retain" }}
    whenScaled: {{ $root.Values.persistentVolumeClaimRetentionPolicy.whenScaled | default "Retain" }}
  {{- with $root.Values.volumeClaimTemplates }}
  volumeClaimTemplates:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end }}