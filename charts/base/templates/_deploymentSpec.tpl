
{{/*
extra pod volumes
*/}}
{{- define "base.extraVolumes" -}}
{{- if .Values.extraContainers }}
{{- range $containerName, $containerValues := .Values.extraContainers }}
{{- with $containerValues.volumes }}
{{ toYaml . }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
pod volumes
*/}}
{{- define "base.volumes" -}}
{{- $extraVolumes := include "base.extraVolumes" . -}}
{{- if or $extraVolumes .Values.volumes -}}
volumes:
{{- if $extraVolumes -}}
  {{ $extraVolumes | trim | nindent 2 }}
{{- end }}
{{- with .Values.volumes -}}
  {{ toYaml . | nindent 2 }}
{{- end }}
{{- end }}
{{- end }}


{{/*
pod affinity
*/}}
{{- define "base.affinity" -}}
{{- $podAntiAffinity := .Values.podAntiAffinity | default dict -}}
{{- if or .Values.affinity $podAntiAffinity.enabled }}
{{- $deploymentValues := . -}}
affinity:
{{- with .Values.affinity }}
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- if $podAntiAffinity.enabled }}
  podAntiAffinity:
  {{- if eq $podAntiAffinity.type "hard" }}
    requiredDuringSchedulingIgnoredDuringExecution:
    {{- range $key, $value := $podAntiAffinity.topology }}
    - labelSelector:
        matchExpressions:
        {{- range $key, $value := $deploymentValues | include "base.selectorLabels" | toString | fromYaml }}
        - key: {{ $key }}
          operator: In
          values:
          - {{ $value }}
        {{- end }}
      topologyKey: {{ .topologyKey }}
    {{- end }}
  {{- else }}
    preferredDuringSchedulingIgnoredDuringExecution:
    {{- range $key, $value := $podAntiAffinity.topology }}
    - weight: {{ .weight | default 100 }}
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          {{- range $key, $value := $deploymentValues | include "base.selectorLabels" | toString | fromYaml }}
          - key: {{ $key }}
            operator: In
            values:
            - {{ $value }}
          {{- end }}
        topologyKey: {{ .topologyKey }}
      {{- end }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}

{{/*
define container vars
*/}}
{{- define "base.environment" -}}
{{- if .environment }}
env:
{{- range $variableName, $opts := .environment.secretVariables }}
  - name: {{ $variableName }}
    valueFrom:
      secretKeyRef:
        name: {{ $opts.secretName }}
        key: {{ $opts.dataKeyRef }}
{{- end }}
{{- range $variableName, $opts := .environment.configmapVariables }}
  - name: {{ $variableName }}
    valueFrom:
      configMapKeyRef:
        name: {{ $opts.configmapName }}
        key: {{ $opts.dataKeyRef }}
{{- end }}
{{- range $key, $value := .environment.variables }}
  - name: {{ $key | quote }}
    value: {{ $value | quote }}
{{- end }}
{{- range $variableName, $value := .environment.metadata }}
  - name: {{ $variableName }}
    valueFrom:
      fieldRef:
        fieldPath: {{ $value }}
{{- end }}
{{- range $configMapName := .environment.envFromConfigMaps }}
envFrom:
  - configMapRef:
      name: {{ $configMapName }}
{{- end }}
{{- end }}
{{- end }}