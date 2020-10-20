---
jupyter:
  jupytext:
    text_representation:
      extension: .Rmd
      format_name: rmarkdown
      format_version: '1.2'
      jupytext_version: 1.6.0
  kernelspec:
    display_name: Python 3
    language: python
    name: python3
title: "Classification: premier modèle avec les SVM"
date: 2020-10-15T13:00:00Z
draft: false
weight: 30
output: 
  html_document:
    keep_md: true
    self_contained: true
slug: SVM
---





Pour illustrer le travail de données nécessaire pour construire un modèle de Machine Learning, mais aussi nécessaire pour l'exploration de données avant de faire une régression linéaire, nous allons partir du jeu de données de [résultat des élections US 2016 au niveau des comtés](https://public.opendatasoft.com/explore/dataset/usa-2016-presidential-election-by-county/download/?format=geojson&timezone=Europe/Berlin&lang=fr)


{{% panel status="exercise" title="Exercise 1: importer les données" icon="fas fa-pencil-alt" %}}
1. Importer les données (l'appeler `df`) des élections américaines et regarder les informations dont on dispose
2. Créer une variable `republican_winner` égale à `red`  quand la variable `rep16_frac` est supérieure à `dep16_frac` (`blue` sinon)
3. Représenter une carte des résultats avec en rouge les comtés où les républicains ont gagné et en bleu ceux où se sont
les démocrates
{{% /panel %}}




## La régression linéaire

## La régression logistique

## Modèles linéaires généralisés

## Tests d'hypothèses

