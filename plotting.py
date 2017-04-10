import matplotlib.pyplot as plt
import matplotlib
from matplotlib.figure import Figure
from matplotlib.dates import DateFormatter, num2date
import matplotlib.patches as patches
import numpy as np

class Plots:
    def __init__(self):
        self.rects = []
        self.figure = None
        self.axes = []
        self.clicked = None

    def generate_subplots(self, x, *args):
        def _on_xlims_change(axes):
            # reset the x-axis format when the plot is resized
            axes.get_xaxis().set_major_formatter(DateFormatter('%H:%M:%S'))

        i = 0
        numplots = len(args)
        fig = plt.figure()

        self.cidclick = fig.canvas.mpl_connect('button_press_event', self.onclick)
        self.cidrelease = fig.canvas.mpl_connect('button_release_event', self.onrelease)
        self.cidmotion = fig.canvas.mpl_connect('motion_notify_event', self.onmotion)

        for arg in args:
            if i == 0:
                a = fig.add_subplot(numplots, 1, i+1)
            else:
                a = fig.add_subplot(numplots, 1, i+1, sharex=self.axes[0])

            a.plot(x.to_pydatetime(), arg)
            a.fmt_xdata = DateFormatter('%H:%M:%S')
            a.grid(True)
            a.callbacks.connect('xlim_changed', _on_xlims_change)
            self.axes.append(a)
            i += 1

        if not matplotlib.is_interactive():
            fig.show()

        self.figure = fig

    def onmotion(self, event):
        if self.clicked is None: return

        partners, index, x0, xclick, yclick = self.clicked

        # move rectangles
        dx = event.xdata - xclick
        for rect in partners:
            rect.set_x(x0 + dx)

        self.figure.canvas.draw()

    def onrelease(self, event):
        self.clicked = None
        self.figure.canvas.draw()

    def onclick(self, event):
        # TO DO: Don't place rectangle when zooming.
        # TO DO: Resize rectangles when plot extent changes.
        # TO DO: Make more efficient. Detect which plot is clicked?

        for partners in self.rects:
            index = 0
            for rect in partners:
                contains, attrd = rect.contains(event)
                if contains:
                    x0, _ = rect.xy
                    self.clicked = partners, index, x0, event.xdata, event.ydata
                    return
                index += 1

        partners = []
        for subplot in self.figure.axes:
            ylim = subplot.get_ylim()
            xlim = subplot.get_xlim()
            x_extent = (xlim[-1] - xlim[0]) * np.float64(0.1)

            # bottom left corner
            x0 = event.xdata - x_extent/2
            y0 = ylim[0]
            width = x_extent
            height = ylim[-1] - ylim[0]
            r = patches.Rectangle((x0, y0), width, height, alpha=0.1)
            # self.rects.append(r)
            partners.append(r)
            # rect = subplot.add_patch(r)
            subplot.add_patch(r)

        self.rects.append(partners)
        # self.rect.figure.canvas.draw()
        self.figure.canvas.draw()
