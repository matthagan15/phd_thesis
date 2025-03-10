import json
from os import walk
from os.path import isfile, join
import matplotlib.pyplot as plt
from math import sqrt
import numpy as np


def load_data():
    filename = "/Users/matt/repos/thermal_state_prep/numerics/tmp/capture_radius/harmonic_oscillator_high_temp.json"
    with open(filename) as f:
        json_data =json.load(f)
        print("keys:")
        print(json_data.keys())
        alpha = json_data["alpha"]
        time = json_data["time"]
        deltas = json_data["deltas"]
        input_distances = json_data["thermal_state_distances"]
        channel_outputs = json_data["channel_output_distances"]
        means, stds, dist_of_avgs = [], [], []
        for x in channel_outputs:
            means.append(x[0])
            stds.append(x[1])
            dist_of_avgs.append(x[2])
        return (alpha, time, deltas, input_distances, means, stds, dist_of_avgs)
        

def plot_gap(alpha, beta, gammas, means, stds):
    """assumes means and stds are dictionaries that map (a,b,c) -> mean. """
    x = list(gammas)
    y = []
    yerr = []
    for i in x:
        y.append(means[(alpha, beta, i)])
        yerr.append(stds[(alpha, beta, i)])
    fig = plt.figure()
    # plt.yscale('log', nonposy='clip')
    plt.errorbar(x, y, yerr, label="alpha = {:.4f}\nbeta_sys = {:.4f}".format(alpha, beta), fmt="r+")
    plt.legend(loc = 'lower right')
    plt.title("Trace distance after 1 interaction, env_beta = 0.5, system gap = 1.0")
    plt.xlabel("Environment Gap")
    plt.ylabel("Normalized trace distance ideal to output")
    plt.show()

if __name__ == "__main__":
    (alpha, time, deltas, input_distances, means, stds, dist_of_avgs) = load_data()
    fig = plt.figure()
    plt.yscale('log', nonpositive='clip')
    plt.xscale('log', nonpositive='clip')
    plt.plot(deltas, input_distances, label = "input distance to target")
    plt.plot(deltas, dist_of_avgs, label = "dist of avg")
    plt.errorbar(deltas, means, stds, label = "channel outputs")
    plt.xlabel("Delta = Beta_E - Beta")
    plt.ylabel("schatten 2 distance")
    plt.legend(loc = 'upper left')
    plt.show()
