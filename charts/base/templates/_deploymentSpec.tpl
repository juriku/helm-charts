{{/*
define container image
*/}}
{{- define "base.image" -}}
image: "{{ .repository }}:{{ .tag | toString }}"
{{- if regexMatch "[0-9]" ( .tag | toString ) }}
imagePullPolicy: {{ .pullPolicy }}
{{- else }}
imagePullPolicy: "Always"
{{- end }}
{{- end }}

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
{{- $deploymentValues := . -}}
{{- if or .Values.affinity $podAntiAffinity.enabled }}
affinity:
{{- with .Values.affinity }}
{{ toYaml . | indent 2 }}
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
deployemnt Node Scheduling
*/}}
{{- define "base.NodeScheduling" -}}
{{- include "base.affinity" . }}
{{- if .Values.nodeSelector }}
nodeSelector:
{{ toYaml .Values.nodeSelector | indent 2 }}
{{- else if .Values.nodeSelectorDefault }}
nodeSelector:
{{ toYaml .Values.nodeSelectorDefault | indent 2 }}
{{- end }}
{{- with .Values.tolerations }}
tolerations:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}

{{/*
define container vars
*/}}
{{- define "base.environment" -}}
{{- if .environment }}
{{- if or .environment.envFromConfigMaps .environment.envFromSecrets }}
envFrom:
{{- range $configMapName := .environment.envFromConfigMaps }}
  - configMapRef:
      name: {{ $configMapName }}
{{- end }}
{{- range $configMapName := .environment.envFromSecrets }}
  - secretRef:
      name: {{ $configMapName }}
{{- end }}
{{- end }}
env:
{{- range $variableName, $value := .environment.metadata }}
  - name: {{ $variableName }}
    valueFrom:
      fieldRef:
        fieldPath: {{ $value }}
{{- end }}
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
    value: {{ $value | toString | default "" | quote }}
{{- end }}
{{- end }}
{{- end }}

{{/*
define pod probes
*/}}
{{- define "base.podProbes" -}}
{{- with .livenessProbe }}
livenessProbe:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .readinessProbe }}
readinessProbe:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .startupProbe }}
startupProbe:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}

{{/*
define pod lifecycle
*/}}
{{- define "base.podLifecycle" -}}
{{- with .lifecycle }}
lifecycle:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}

{{/*
define pod resources
*/}}
{{- define "base.podResources" -}}
{{- with .resources }}
resources:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}

{{/*
define pod security
*/}}
{{- define "base.podSecurity" -}}
{{- with .securityContext }}
securityContext:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}

{{/*
define container security
*/}}
{{- define "base.containerSecurity" -}}
{{- with .podSecurityContext }}
securityContext:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}

{{/*
define container security
*/}}
{{- define "base.imagePullSecrets" -}}
{{- if .imagePullSecrets }}
imagePullSecrets:
{{- range .imagePullSecrets }}
  - name: {{ . }}
{{- end }}
{{- end }}
{{- end }}

{{/*
define pod security
*/}}
{{- define "base.podVolumeMounts" -}}
{{- with .volumeMounts }}
volumeMounts:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}

{{/*
define pod command and args
*/}}
{{- define "base.podCommand" -}}
{{- with .command }}
command:
{{ toYaml . | indent 2 }}
{{- end }}
{{- with .args }}
args:
{{ toYaml . | indent 2 }}
{{- end }}
{{- end }}

{{/*
define pod service account
*/}}
{{- define "base.serviceAccount" -}}
{{- if .serviceAccountName }}
serviceAccountName: {{ .serviceAccountName }}
{{- end }}
{{- with .automountServiceAccountToken }}
automountServiceAccountToken: {{ .enabled }}
{{- end }}
{{- end }}

{{/*
define default pod properties
*/}}
{{- define "base.podDefaultProperties" -}}
{{- include "base.podCommand" . }}
{{- include "base.podSecurity" . }}
{{- include "base.environment" . }}
{{- include "base.podProbes" . }}
{{- include "base.podLifecycle" . }}
{{- include "base.podResources" . }}
{{- include "base.podVolumeMounts" . }}
{{- end }}

{{/*
define default container properties
*/}}
{{- define "base.containerDefaultProperties" -}}
{{- include "base.imagePullSecrets" .Values }}
{{- include "base.containerSecurity" .Values }}
{{- include "base.NodeScheduling" . }}
{{- include "base.serviceAccount" .Values }}
{{- end }}
