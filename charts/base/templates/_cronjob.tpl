{{- define "base.cronjob" -}}
{{- $root := . -}}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ include "base.fullname" $root }}
  {{- if $root.Values.namespace }}
  namespace: {{ $root.Values.namespace }}
  {{- end }}
  labels:
    {{- include "base.commonLabels" $root | trim | nindent 4 }}
  {{- if $root.Values.annotations }}
  annotations:
    {{- include "base.valuesPairs" $root.Values.annotations | trim | nindent 4 }}
  {{- end }}
spec:
  {{- if $root.Values.concurrencyPolicy }}
  concurrencyPolicy: {{ $root.Values.concurrencyPolicy }}
  {{- end }}
  {{- if $root.Values.failedJobsHistoryLimit }}
  failedJobsHistoryLimit: {{ $root.Values.failedJobsHistoryLimit }}
  {{- end }}
  {{- if $root.Values.successfulJobsHistoryLimit }}
  successfulJobsHistoryLimit: {{ $root.Values.successfulJobsHistoryLimit }}
  {{- end }}
  {{- if $root.Values.startingDeadlineSeconds }}
  startingDeadlineSeconds: {{ $root.Values.startingDeadlineSeconds }}
  {{- end }}
  schedule: {{ $root.Values.schedule | quote }}
  {{- if $root.Values.suspend }}
  suspend: {{ $root.Values.suspend }}
  {{- end }}
  jobTemplate:
    spec:
      {{- if $root.Values.backoffLimit }}
      backoffLimit: {{ $root.Values.backoffLimit }}
      {{- end }}
      {{- if $root.Values.ttlSecondsAfterFinished }}
      ttlSecondsAfterFinished: {{ $root.Values.ttlSecondsAfterFinished }}
      {{- end }}
      {{- if $root.Values.activeDeadlineSeconds }}
      activeDeadlineSeconds: {{ $root.Values.activeDeadlineSeconds }}
      {{- end }}
      {{- if $root.Values.completions }}
      completions: {{ $root.Values.completions }}
      {{- end }}
      {{- if $root.Values.parallelism }}
      parallelism: {{ $root.Values.parallelism }}
      {{- end }}
      template:
        metadata:
          {{- if $root.Values.podAnnotations }}
          annotations:
            {{- include "base.valuesPairs" $root.Values.podAnnotations | trim | nindent 12 }}
          {{- end }}
          labels:
            {{- include "base.labels" $root | trim | nindent 12 }}
            {{- with $root.Values.podLabels }}
            {{- toYaml . | nindent 12 }}
            {{- end }}
        spec:
          {{- with include "base.podDefaultProperties" $root }}
          {{- . | trim | nindent 10 }}
          {{- end }}
          {{- if $root.Values.podActiveDeadlineSeconds }}
          activeDeadlineSeconds: {{ $root.Values.podActiveDeadlineSeconds }}
          {{- end }}
          {{- with include "base.initContainers" $root }}
          {{- . | trim | nindent 10 }}
          {{- end }}
          {{- include "base.containers" $root | trim | nindent 10 }}
          {{- with include "base.volumes" $root }}
          {{- . | trim | nindent 10 }}
          {{- end }}
      {{- with $root.Values.podFailurePolicy }}
      podFailurePolicy:
        {{- toYaml . | nindent 8 }}
      {{- end }}
{{- end }}
