{{- define "base.cronjob" -}}
{{- $deploymentValues := . -}}
---
apiVersion: {{ $deploymentValues.Values.apiVersion | default "batch/v1" }}
kind: CronJob
metadata:
  name: {{ include "base.fullname" $deploymentValues }}
  {{- if $deploymentValues.Values.namespace }}
  namespace: {{ $deploymentValues.Values.namespace }}
  {{- end }}
  labels:
    {{- include "base.commonLabels" $deploymentValues | trim | nindent 4 }}
  {{- if $deploymentValues.Values.annotations }}
  annotations:
    {{- include "base.valuesPairs" $deploymentValues.Values.annotations | trim | nindent 4 }}
  {{- end }}
spec:
  {{- if $deploymentValues.Values.concurrencyPolicy }}
  concurrencyPolicy: {{ $deploymentValues.Values.concurrencyPolicy }}
  {{- end }}
  {{- if $deploymentValues.Values.failedJobsHistoryLimit }}
  failedJobsHistoryLimit: {{ $deploymentValues.Values.failedJobsHistoryLimit }}
  {{- end }}
  {{- if $deploymentValues.Values.successfulJobsHistoryLimit }}
  successfulJobsHistoryLimit: {{ $deploymentValues.Values.successfulJobsHistoryLimit }}
  {{- end }}
  {{- if $deploymentValues.Values.startingDeadlineSeconds }}
  startingDeadlineSeconds: {{ $deploymentValues.Values.startingDeadlineSeconds }}
  {{- end }}
  schedule: {{ $deploymentValues.Values.schedule | quote }}
  {{- if $deploymentValues.Values.suspend }}
  suspend: {{ $deploymentValues.Values.suspend }}
  {{- end }}
  jobTemplate:
    spec:
      {{- if $deploymentValues.Values.backoffLimit }}
      backoffLimit: {{ $deploymentValues.Values.backoffLimit }}
      {{- end }}
      {{- if $deploymentValues.Values.ttlSecondsAfterFinished }}
      ttlSecondsAfterFinished: {{ $deploymentValues.Values.ttlSecondsAfterFinished }}
      {{- end }}
      {{- if $deploymentValues.Values.activeDeadlineSeconds }}
      activeDeadlineSeconds: {{ $deploymentValues.Values.activeDeadlineSeconds }}
      {{- end }}
      {{- if $deploymentValues.Values.completions }}
      completions: {{ $deploymentValues.Values.completions }}
      {{- end }}
      {{- if $deploymentValues.Values.parallelism }}
      parallelism: {{ $deploymentValues.Values.parallelism }}
      {{- end }}
      template:
        {{- if or $deploymentValues.Values.podAnnotations $deploymentValues.Values.podLabels }}
        metadata:
          {{- if $deploymentValues.Values.podAnnotations }}
          annotations:
            {{- include "base.valuesPairs" $deploymentValues.Values.podAnnotations | trim | nindent 12 }}
          {{- end }}
          {{- with $deploymentValues.Values.podLabels }}
          labels:
            {{- toYaml . | nindent 12 }}
          {{- end }}
        {{- end }}
        spec:
          {{- with include "base.podDefaultProperties" $deploymentValues }}
          {{- . | trim | nindent 10 }}
          {{- end }}
          {{- if $deploymentValues.Values.podActiveDeadlineSeconds }}
          activeDeadlineSeconds: {{ $deploymentValues.Values.podActiveDeadlineSeconds }}
          {{- end }}
          {{- if $deploymentValues.Values.initContainers }}
          initContainers:
            {{- range $containerName, $containerValues := $deploymentValues.Values.initContainers }}
            - name: {{ $containerName }}
              {{- include "base.image" (merge dict $containerValues.image $deploymentValues.Values.image) | nindent 10 }}
              {{- with include "base.containerDefaultProperties" $containerValues }}
              {{- . | trim | nindent 14 }}
              {{- end }}
            {{- end }}
          {{- end }}
          containers:
            {{- range $containerName, $containerValues := $deploymentValues.Values.extraContainers }}
            - name: {{ $containerName }}
              {{- include "base.image" (merge dict $containerValues.image $deploymentValues.Values.image) | nindent 14 }}
              {{- with include "base.containerDefaultProperties" $containerValues }}
              {{- . | trim | nindent 14 }}
              {{- end }}
            {{- end }}
            - name: {{ include "base.name" $deploymentValues }}
              {{- include "base.image" $deploymentValues.Values.image | nindent 14 }}
              {{- with include "base.containerDefaultProperties" $deploymentValues.Values }}
              {{- . | trim | nindent 14 }}
              {{- end }}
          {{- with include "base.volumes" $deploymentValues }}
          {{- . | trim | nindent 10 }}
          {{- end }}
      {{- with $deploymentValues.Values.podFailurePolicy }}
      podFailurePolicy:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end }}
