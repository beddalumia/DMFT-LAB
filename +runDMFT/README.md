# `runDMFT`
Running QcmPlab DMFT codes from MATLAB

----------

### Choose your favorite workflow

#### Production

- `dry_line()` The most basic scenario: linear increase of U, no feedback, just some noninvasive check of convergence to flag out, _a posteriori_, which points should be discarded. 

- `autostop_line()` Basic linspace in U, without any adaptive feedback mechanism. Just stops the moment dmft does not converge (to avoid wasting cpu-time).

- `autostep_line()` Gradually increases U by feedback-controlled steps, i.e. if dmft does not converge the point is discarded and the step reduced. Self-mixing is fixed (as every other control variable).


#### Refinement

- `refresh_line()` Systematically enters the folder structure of a pre-existent calculation and uses the given _used_ files as a _restart_ to perform some additional dmft loops. Useful if something has been added to the driver. [WORK-IN-PROGRESS, see [Issue #1](https://github.com/bellomia/DMFT-LAB/issues/1)]

#### Testing & Setup

- `interactive_line()` Interactive-ish workflow: on-the-flight manual updates of the inputfile, while dmft waits for you (in a dumb way); Hubbard steps are inevitably fixed.

----------

### TODO

- [ ] `automixing_line()` Automatic control of self-mixing. Requires inspecting evolution of the dmft error, could be cumbersome (better handled at a lower level, e.g. within the dmft-loop driver: see [`adaptive_mix()`](https://github.com/QcmPlab/SciFortran/blob/master/src/SF_OPTIMIZE/adaptive_mix.f90) in SciFortran).

- [ ] `array_line()` A variant of `dry_line()` that exploits the array-env-variables provided by `SLURM` on HPC facilities. [**PRIORITY**]
