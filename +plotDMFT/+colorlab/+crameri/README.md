CRAMERI Colormap Package
========================



## Overview: colorschemes and main functionalities ##

![Brewer_TABLE](assets/crameri_show.png)

The above table, showing all the discrete schemes defined in the package, can be retrieved at run time by invoking the `crameri.show` command.

### Examples: command line usage through `crameri.cmap()` function ###

```matlab
    % Brewer colors for a sample PHOTO:
    S = load('mandrill');
    imshow(S.X,colormap(brewer.cmap([],"-YlGnBu"))) % reversed yellow-green-blue scheme
```
![invYlGnBu](assets/mandrill_invYlGnBu.png)
```matlab
    % Brewer colors for a sample SURF:
    [X,Y,Z] = peaks(50);
    surfc(X,Y,Z)
    colormap(brewer.cmap([],'-RdBu')) % reversed red-blue divergent scheme
```
![invRdBu](assets/surfc_invRdBu.png)
```matlab
    % A trick to deal with nasty CONTOURCMAP function (Mapping Toolbox):
    preset_colormap(@brewer.cmap, '-PuOr'); % preselect the colorscheme.
    load topo
    load coastlines
    figure
    worldmap(topo, topolegend)
    contourfm(topo, topolegend);
    contourcmap('parula', 'Colorbar','on', 'Location','horizontal');
    %            ^ temporary use of parula...
    plotm(coastlat, coastlon, 'k'); colormap(preset_colormap); % Et Voilà...
    % -> we have set our beautiful purple-orange colormap afterwards!
```
![invPuOr](assets/worldmap_brewer.svg)
```matlab
    % Plot and compare RGB values:
    ax(1) = subplot(1,2,1); 
    cmap = brewer.cmap(NaN, 'PiYG');
    rgbplot(cmap); title('Standard PiYG')
    xlim([1,11]); xticks([]);
    colorbar('southoutside');
    colormap(ax(1),cmap); 

    ax(2) = subplot(1,2,2);
    cmap = brewer.cmap(NaN,'-PiYG');
    rgbplot(cmap); title('Reversed PiYG')
    xlim([1,11]); xticks([]);
    colorbar('southoutside');
    colormap(ax(2),cmap);
```
![rgb_plot](assets/rgbplot.svg)
```matlab    
    % View information about a colorscheme:

    >> [~,num,typ] = brewer.cmap(NaN,'Paired')
    
    num =

        12


    typ =

        'Qualitative'
```
```matlab
    % Multiline plot using matrices:
    N = 6;
    axes('ColorOrder',brewer.cmap(N,'Pastel2'),'NextPlot','replacechildren')
    X = linspace(0,3*pi,1000);
    Y = bsxfun(@(x,n)n*sin(x+2*n*pi/N), X.', 1:N);
    plot(X,Y, 'linewidth',4); box on; xlim([0,3*pi]);
```
![Pastel2](assets/pastel2.svg)
```matlab
    % Multiline plot in a loop:
    set(0,'DefaultAxesColorOrder',brewer.cmap(NaN,'Accent'))
    N = 6;
    X = linspace(0,10,1000);
    Y = bsxfun(@(x,n)n*sin(x+2*n*pi/N), X.', 1:N);
    for n = 1:N
        plot(X(:),Y(:,n), 'linewidth',4);
        hold all
    end
    xlim([0,3*pi]);
```
![Accent](assets/accent.svg)

### Upgrading: retrieve any release on ZENODO with `crameri.update()` ###



### How to make a scheme permanent: `preset_colormap()` function ###

PRESET_COLORMAP is a wrapper for any colormap function, storing the function and any parameter values for future calls.

```matlab
    preset_colormap(@crameri.cmap, "berlin")
    colormap(preset_colormap)
```

### COPYRIGHT & LICENSING ###

 © 2014-2022 Stephen Cobeldick, original [BREWERMAP Function](https://github.com/DrosteEffect/BrewerMap)    
 © 2022 Gabriele Bellomia, +BREWER Package adaptation and embedding

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at:

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and limitations under the License.


[^1]: This product includes color specifications and designs developed by Cynthia Brewer (http://colorbrewer.org/). See the ColorBrewer website for further information about each colorscheme, colorblind suitability, licensing, and citations.